module Trinidad
  module Extensions
    gem 'jruby-lint'
    require 'jruby/lint'

    class DiagnosticsWebAppExtension < WebAppExtension
      VERSION = '0.1.0'

      def configure(tomcat, app_context)
        app_context.add_lifecycle_listener DiagnosticsListener.new(@options[:debug])
      end
    end

    class DiagnosticsOptionsExtension < OptionsExtension
      def configure(parser, default_options)
        default_options[:extensions] ||= {}
        default_options[:extensions][:diagnostics] = {}

        parser.on('--dd', '--diagnostics-debug', 'Append diagnostics to the console log') do
          default_options[:extensions][:diagnostics] ||= {}
          default_options[:extensions][:diagnostics][:debug] = true
        end
      end
    end

    class DiagnosticsListener
      require 'ostruct'
      include Trinidad::Tomcat::LifecycleListener

      def initialize(debug)
        @debug = debug || false
      end

      def lifecycleEvent(event)
        if event.type == Trinidad::Tomcat::Lifecycle::BEFORE_START_EVENT
          puts '-- Trinidad diagnostics on' if @debug
          app_context = event.lifecycle

          options = OpenStruct.new(
            :html => report_output(app_context),
            :chdir => app_context.doc_base,
            :text => @debug)

          project = JRuby::Lint::Project.new(options)
          project.run
          puts '-- Trinidad diagnostics off' if @debug
        end
      end

      def report_output(app_context)
        public_root = app_context.find_parameter('public.root') || 'public'
        File.join(public_root, 'diagnostics.html')
      end
    end
  end
end
