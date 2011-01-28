path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'mongo'
require 'json'
require File.join(path,'../quality-measure-engine')

patient_template_dir = ENV['PATIENT_TEMPLATE_DIR'] || File.join('fixtures', 'patient_templates')
db_name = ENV['DB_NAME'] || 'test'
loader = QME::Database::Loader.new(db_name)

namespace :patient do

  desc 'Generate n (default 10) random patient records and save them in the database'
  task :random, :n do |t, args|
    n = args.n.to_i>0 ? args.n.to_i : 1
    
    templates = []
    Dir.glob(File.join(patient_template_dir, '*.json.erb')).each do |file|
      templates << File.read(file)
    end
    
    map = QME::MapReduce::Executor.new(loader.get_db)
    map.all_measures.each do |measure_id, measure_def|
      QME::Importer::PatientImporter.instance.add_measure(measure_id, QME::Importer::GenericImporter.new(measure_def))
    end

    n.times do
      template = templates[rand(templates.length)]
      generator = QME::Randomizer::Patient.new(template)
      json = JSON.parse(generator.get())
      patient_record = QME::Importer::PatientImporter.instance.parse_hash(json)
      loader.save('records', patient_record)
    end
  end
    
end