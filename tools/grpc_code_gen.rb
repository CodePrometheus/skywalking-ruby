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

require 'fileutils'

ROOT_DIR = File.expand_path('..', __dir__)
OUT_DIR = File.join(ROOT_DIR, 'lib', 'skywalking_ruby/proto')

FileUtils.mkdir_p(OUT_DIR)

Dir.chdir(File.join(ROOT_DIR, 'protocol')) do
  system("grpc_tools_ruby_protoc -I. --ruby_out=#{OUT_DIR} --grpc_out=#{OUT_DIR} **/*.proto")
end