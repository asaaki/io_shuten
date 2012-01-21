if ENV["COV"] || ENV["COVERAGE"]
  require 'simplecov-rcov'
  require 'simplecov-csv'
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
       SimpleCov::Formatter::RcovFormatter.new.format(result)
       SimpleCov::Formatter::HTMLFormatter.new.format(result)
       SimpleCov::Formatter::CSVFormatter.new.format(result)
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
  SimpleCov.start do
    add_filter "/spec/"
  end
end

