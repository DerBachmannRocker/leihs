#!/usr/bin/env ruby
require 'yaml'

CI_SCENARIOS_PER_TASK = (ENV['CI_SCENARIOS_PER_TASK'] || 5).to_i
STRICT_MODE = true

def task_hash(name, exec)
  h = { 'name' => name,
        'scripts' => {
            'test' => {
                'body' => exec
            }
        }
      }
  h
end

def task_for_feature_file file_path, _timeout = 200
  name= file_path.match(/features\/(.*)\.feature/).captures.first
  exec = %{DISPLAY=\":$XVNC_PORT\" bundle exec cucumber -p default -f json -o log/cucumber_report.json #{STRICT_MODE ? "--strict " : nil}"#{file_path}"}
  task_hash(name, exec)
end

feature_files = Dir.glob('features/**/*.feature') - Dir.glob('features/personas/*.feature') - Dir.glob('features/**/*.feature.disabled')
filepath = './.cider-ci/tasks/cucumber.yml'
File.open(filepath,'w') do |f|
  string = {'tasks' => feature_files.map do |f|
    task_for_feature_file(f)
  end}
  f.write(string.to_yaml)
end

default_browser = ENV['DEFAULT_BROWSER'] ? ENV['DEFAULT_BROWSER'] : :firefox # [:firefox, :chrome].sample
filepath = './.cider-ci/tasks/cucumber_scenarios.yml'
File.open(filepath,'w') do |f|
  h1 = {}
  `egrep -R -n -B 1 "^\s*(Scenario|Szenario)" features/* engines/**/features/*`.split("--\n").map{|x| x.split("\n")}.each do |t, s|
    next if t =~ /@old-ui|@upcoming|@generating_personas|@manual/
    splitted_string = s.split(/:\s*(Scenario|Szenario)( Outline| Template|grundriss)?: /)
    k, v = splitted_string.first.split(':')
    h1[k] ||= []
    h1[k] << v
  end.compact

  h2 = []
  h1.map do |k,v|
    require = k =~ /^engines/ ? "-r engines/**/features" : nil
    v.each_slice(CI_SCENARIOS_PER_TASK) do |lines|
      path = ([k] + lines).join(':')
      exec = "DISPLAY=\":$XVNC_PORT\" bundle exec cucumber -p default %s -f json -o log/cucumber_report.json #{STRICT_MODE ? "--strict " : nil}%s DEFAULT_BROWSER=%s" % [require, path, default_browser]
      h2 << task_hash(path, exec)
    end
  end

  h3 = {'tasks' => h2}

  f.write h3.to_yaml
end
