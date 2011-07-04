require 'spec_helper'

describe 'Trinidad::Extensions::DiagnosticsWebAppExtension' do
  it "add the diagnostics listener to the application context" do
    context = Trinidad::Tomcat::StandardContext.new
    extension = Trinidad::Extensions::DiagnosticsWebAppExtension.new {}
    extension.configure(nil, context)

    context.find_lifecycle_listeners.should have(1).listener
  end
end

describe 'Trinidad::Extensions::DiagnosticsListener' do
  subject { Trinidad::Extensions::DiagnosticsListener }
  let(:context) { Trinidad::Tomcat::StandardContext.new }

  it 'keeps the report file under the public root' do
    listener = subject.new(false)
    context.add_parameter('public.root', 'foo')

    file_path = listener.report_output(context)
    file_path.should == 'foo/diagnostics.html'
  end

  it "uses `public' as default path to keep the report" do
    listener = subject.new(false)

    file_path = listener.report_output(context)
    file_path.should == 'public/diagnostics.html'
  end

  it "uses the context doc base as root directory to inspect" do
    listener = subject.new(false)
    context.doc_base = Dir.pwd

    options = listener.lint_options(context)
    options.chdir.should == Dir.pwd
  end

  it "appends a text reporter when the debug option is enabled" do
    listener = subject.new(true)

    options = listener.lint_options(context)
    options.text.should == true
  end

  it "uses the report output as html report file path" do
    listener = subject.new(true)

    options = listener.lint_options(context)
    options.html.should == listener.report_output(context)
  end

  it "runs the diagnostics before the application starts" do
    listener = subject.new(false)
    event = mock
    event.should_receive(:type).and_return Trinidad::Tomcat::Lifecycle::BEFORE_START_EVENT
    event.should_receive(:lifecycle).and_return context
    listener.should_receive(:run_diagnostics)

    listener.lifecycleEvent event
  end

  it "does not run the diagnostics on any other event" do
    listener = subject.new(false)
    event = mock
    event.should_receive(:type).and_return Trinidad::Tomcat::Lifecycle::AFTER_START_EVENT
    event.should_not_receive(:lifecycle)
    listener.should_not_receive(:run_diagnostics)

    listener.lifecycleEvent event
  end
end
