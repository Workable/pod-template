module Pod

  class ConfigureSwift
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def remove_line_from_podspec!(matches)
      filename = "NAME.podspec"
      lines = File.readlines(filename)
      File.open(filename, "w") do |f|
        lines.each { |line| f.puts(line) unless line.include? matches }
      end
    end

    def perform
      configurator.add_pod_to_podfile "Quick', '~> 2.0"
      configurator.add_pod_to_podfile "Nimble', '~> 8.0"
      configurator.set_test_framework "quick", "swift", "swift"

      keep_demo = configurator.ask_with_answers("Would you like to include a demo application with your module", ["Yes", "No"]).to_sym
      snapshots = configurator.ask_with_answers("Is your module view based", ["Yes", "No"]).to_sym

      case snapshots
      when :yes
        if keep_demo == :no
            puts " Putting demo application back in, you cannot do view tests without a host application."
            keep_demo = :yes
        end
        configurator.add_pod_to_podfile "Nimble-Snapshots"
        remove_line_from_podspec! "s.script_phase = {}"
      else 
        remove_line_from_podspec! "test_spec.requires_app_host = true"
        remove_line_from_podspec! "test_spec.dependency 'Nimble-Snapshots'"
      end

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "templates/swift/Example/PROJECT.xcodeproj",
        :platform => :ios,
        :remove_demo_project => (keep_demo == :no),
        :prefix => ""
      }).run

      `mv ./templates/swift/* ./`

      # There has to be a single file in the Classes dir
      # or a framework won't be created
      `touch Pod/Sources/Sources/ReplaceMe.swift`
      `touch Pod/Sources/ignore.file`
      
      `touch Pod/Tests/Test\\ Sources/Tests.swift`
      `touch Pod/Tests/ignore.file`

      `touch Pod/Resources/ignore.file`

      # The Podspec should be 8.0 instead of 7.0
      text = File.read("NAME.podspec")
      text.gsub!("7.0", "8.0")
      File.open("NAME.podspec", "w") { |file| file.puts text }

      # remove podspec for osx
      `rm ./NAME-osx.podspec`
    end
  end

end
