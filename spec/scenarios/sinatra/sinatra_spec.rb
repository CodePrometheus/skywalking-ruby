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

require 'testcontainers/compose'
require 'faraday'
require_relative '../common/validator'

RSpec.describe "Sinatra" do
  include Validator

  let(:root_dir) { File.expand_path(__dir__) }
  let(:client_url) { 'http://localhost:8080/execute' }
  let(:data_validate_url) { 'http://localhost:12800/dataValidate' }
  let(:receive_data_url) { 'http://localhost:12800/receiveData' }

  let(:compose) do
    Testcontainers::ComposeContainer.new(
      filepath: root_dir,
      compose_filenames: ["docker-compose.yml"]
    )
  end

  before(:each) do
    compose.start
    compose.wait_for_http(url: 'http://localhost:8080/execute', timeout: 600)
  end

  after(:each) do
    compose.stop
  end

  it 'test the sinatra plugin' do
    expected_data = File.read(File.join(root_dir, 'expected.yml'))

    with_retries do
      resp = Faraday.post(data_validate_url) do |req|
        req.body = expected_data
        req.headers['Content-Type'] = 'application/x-yaml'
      end
      unless resp.status == 200
        actual_data = Faraday.get(receive_data_url).body
        raise "Data validation failed, actual Data: #{actual_data} and cause by: #{resp.body}"
      end
    end
  end
end