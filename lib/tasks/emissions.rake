namespace :emissions do
  desc "Imports emissions records from csv in local file system."
  task import_csv: :environment do
    EmissionsImporterJob.perform_later(ENV['csv_folder_path'] + ENV['file_name'])
  end
end
