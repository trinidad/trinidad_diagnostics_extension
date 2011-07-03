require 'jruby-lint'
module Trinidad
  module Extensions
    class DiagnosticsWebAppExtension < WebAppExtension
      VERSION = '0.1.0'

      def configure(tomcat, app_context)
        app_context.add_lifecycle_listener DiagnosticsListener.new
      end
    end

    class DiagnosticsOptionsExtension < OptionsExtension
      def configure(parser, default_options)
        default_options ||= {}
        default_options[:diagnostics] = {}
      end
    end

    class DiagnosticsListener
      require 'ostruct'
      include Trinidad::Tomcat::LifecycleListener

      def lifecycleEvent(event)
        if event.type == Trinidad::Tomcat::Lifecycle::BEFORE_START_EVENT
          app_context = event.lifecycle

          options = OpenStruct.new(:html => report_output(app_context), :chdir => app_context.doc_base)
          project = JRuby::Lint::Project.new(options)
          project.run
        end
      end

      def report_output(app_context)
        public_root = app_context.get_parameter('public.root') || 'public'
        File.join(public_root, 'diagnostics.html')
      end
    end
  end
end
