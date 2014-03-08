require_relative "../../plugin_test_loader"

module AresMUSH
  module Manage
    describe LoadConfigCmd do
      include PluginCmdTestHelper
  
      before do
        init_handler(LoadConfigCmd, "load config")
        SpecHelpers.stub_translate_for_testing
      end
      
      it_behaves_like "a plugin that requires login"
      
      describe :handle do
        before do
          @config_reader = double
          Global.stub(:config_reader) { @config_reader }
        end

        it "should load config and notify client" do           
          @config_reader.should_receive(:read) {}
          client.should_receive(:emit_success).with('manage.config_loaded')
          handler.handle
        end
          
        it "should handle errors from config load" do
          @config_reader.should_receive(:read) { raise "Error" }
          client.should_receive(:emit_failure).with('manage.error_loading_config')
          handler.handle
        end          
      end
    end
  end
end