#  Licensed to the Apache Software Foundation (ASF) under one or more
#  contributor license agreements.  See the NOTICE file distributed with
#  this work for additional information regarding copyright ownership.
#  The ASF licenses this file to You under the Apache License, Version 2.0
#  (the "License"); you may not use this file except in compliance with
#  the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

require "yaml"

module SkywalkingRuby
  class Configuration
    DEFAULTS = {
      'agent_service_name' => 'Your_ApplicationName',
      'agent_instance_name' => 'Your_InstanceName',
      'reporter_discard' => false,
      'reporter_grpc.backend_service' => '127.0.0.1:11800',
      'reporter_grpc.max_send_queue' => '5000',
    }.freeze

    def self.defaults_config
      @defaults_config ||= []
    end

    def self.add_defaults_config(name, file_path: nil)
      defaults_config << {
        :name => name,
        :file_path => file_path,
      }
    end

    def self.determine_file_path
      defaults_config.reverse.each { |default_item|
        file_path = default_item[:file_path]
        return file_path if file_path
      }
      Dir.pwd
    end

    # @api private
    attr_reader :file_path, :agent_config_map, :file_config,
                :env_config, :custom_config

    def initialize(file_path)
      @config_file = config_file
      @file_path = file_path.to_s
      @agent_config_map = {}

      initialize_config
    end

    def initialize_config
      # from the default value
      merge_config(DEFAULTS.transform_values(&:dup))
      # from the custom config file
      @file_config = override_config_by_file || {}
      merge_config(file_config)

      @env_config = override_config_by_env
      merge_config(env_config)
    end

    def config_file
      @config_file ||= file_path.nil? ? nil : File.join(@file_path, 'config', 'agent.yaml')
    end

    def merge_config(config)
      config.each do |k, v|
        agent_config_map[k] = v
      end
    end

    def merge_custom_options(custom_options)
      @custom_options.merge!(custom_options)
      merge_config(custom_options)
    end

    def override_config_by_file
      if !File.exist?(config_file) || !config_file
        p "No config file found at #{config_file}"
        return
      end

      error = nil
      begin
        raw_file = File.read(config_file)
        erb_file = ERB.new(raw_file).result(binding)
        loaded_yaml = YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(erb_file) :
                        YAML.load(erb_file, permitted_classes: [], permitted_symbols: [], aliases: true)
        error = "Invalid format in config file" if loaded_yaml && !loaded_yaml.is_a?(Hash)
      rescue Exception => e
        error = e.message
        nil
      end

      raise Exception, "Error loading config file: #{config_file} - #{error}" if error
      loaded_yaml
    end

    def override_config_by_env
      cfg = {}
      DEFAULTS.each do |key, value|
        env_value = ENV.fetch(key_to_env_key(key), nil)
        next unless env_value
        
        cfg[key] = env_value
      end
      cfg
    end

    def freeze
      super
      agent_config_map.freeze
      agent_config_map.transform_values(&:freeze)
      self
    end

    def key_to_env_key(key)
      'SW_' + key.upcase
    end

    class CustomConfig
      attr_reader :custom_options

      def initialize(config)
        @custom_options = {}
        @config = config
      end

      DEFAULTS.each_key do |option|
        case option.class
        when is_a?(String) do
          define_method(option) do
            fetch_option(option)
          end

          define_method("#{option}=") do |value|
            update_option(option, value.to_s)
          end
        end
        when is_a?(TrueClass) || self.is_a?(FalseClass) do
          define_method(option) do
            fetch_option(option)
          end

          define_method("#{option}=") do |value|
            update_option(option, !!value)
          end
        end

        else
          option
        end
      end

      def fetch_option(key)
        if @custom_options.key?(key)
          @custom_options[key]
        else
          @custom_options[key] = @config[key].dup
        end
      end

      def update_option(key, value)
        @custom_options[key] = value
      end
    end
  end
end
