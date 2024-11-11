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

require 'logger'

module SkywalkingRuby
  class Logger
    def initialize(args = {})
      @args = args
      @log_writer = log_writer
      @logger = ::Logger.new(@log_writer)
      @logger.level = log_level
    end

    def log_writer
      case true
      when stdout?
        STDOUT
      when !@args[:log_file].nil?
        @args[:log_file]
      when !@args[:log_file_path].nil?
        "#{@args[:log_file_path]}/skywalking_ruby.log"
      else
        STDOUT
      end
    end

    def stdout?
      @args[:stdout] || @args[:log_file_path] == "STDOUT"
    end

    def log_level
      case @args[:log_level]
      when "debug" then ::Logger::DEBUG
      when "info" then ::Logger::INFO
      when "warn" then ::Logger::WARN
      when "error" then ::Logger::ERROR
      when "fatal" then ::Logger::FATAL
      else ::Logger::INFO
      end
    end
    
    def info(msg, *args)
      log(:info, msg, *args)
    end
    
    def debug(msg, *args)
      log(:debug, msg, *args)
    end
    
    def warn(msg, *args)
      log(:warn, msg, *args)
    end
    
    def error(msg, *args)
      log(:error, msg, *args)
    end
    
    def log(level, msg, *args)
      if @logger.respond_to?(level)
        if args.empty?
          @logger.send(level, msg)
        else
          @logger.send(level, format(msg, *args))
        end
      else
        Kernel.warn("Unknown log level: #{level}")
      end
    rescue Exception => e
      p "log exception: #{e.message}"
    end
  end
end