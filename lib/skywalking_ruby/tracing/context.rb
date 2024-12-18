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

module SkywalkingRuby
  module Tracing
    class Context
      def new_entry_span
        raise NotImplementedError, 'The new_entry_span method has not been implemented'
      end

      def new_local_span
        raise NotImplementedError, 'The new_local_span method has not been implemented'
      end

      def new_exit_span
        raise NotImplementedError, 'The new_exit_span method has not been implemented'
      end
      
      def start
        raise NotImplementedError, 'The start method has not been implemented'
      end
      
      def stop?
        raise NotImplementedError, 'The stop method has not been implemented'
      end
    end
  end
end
