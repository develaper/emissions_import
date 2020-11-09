# README

Starting with:
git clone https://github.com/develaper/emissions_import.git
followed by:
bundle install
As usual should do the most part of the installation.

* Database creation & Database initialization:

Remember also to do:
rails db:setup
rails db:migrate

* System dependencies:

And also you will need Redis installed locally to ensure that Sidekiq will work as expected.

* How to run the test suite:
For this project I decided to rely in the simplicity of Minitest so, to run the whole suit, you just have to run:
rails test test/

* Running the task and then processing the job:
Our import process will be handled by a rake task that calls to an ActiveJob.

First of all we will check the current value of Emission.count in the rails console just to "manually" validate that everything works fine running:
rails console
Emission.count

The result should be 0 if it is the first time running the task.

Then we need a running server:
rails s
Now that the environment is up and working, open a new tab where you can run the task:
rake emissions:import_csv

At this point we have our job ready to be processed.
Check it out here:
http://localhost:3000/sidekiq/

To end the flow you can force the execution with the command:
bundle exec sidekiq

And now, if you check again the number of Emission.count in the rails console again you will notice a huge increment.


* A note about Figaro, environments and storage:
For easy sharing/testing purpose I have committed and pushed the storage folder and sub-folders as well as the config/application.yml file but under no reason I would never in my live do it in a real environment.
Just saying ;-)


* Facing the challenge:
In order to illustrate how I am use to work I have divided the development in 3 parts. Keeping the focus in a minimal User Story to avoid the addition of before-needed over-complicated solutions.

* Import emissions from csv:
https://github.com/develaper/emissions_import/pull/1
This first PR covers the happy path based on this User Story:
As a user
I want to be able to import a record of emissions from a valid csv file (assuming that all csv files are going to respect the same format)

We have an Emission ApplicationRecord object for each csv record that will be saved to the DB.
The Country is the only required file (through db and ActiveModel validation) to avoid saving useless rows based on the assumption that a row without country is invalid.
But mimicking the info in the csv so even if we have a row with country but the rest of values are empty it will have a record in the DB.
The country field could be improved by adding a collection of country codes and validate that the value in the row is included in the collection.
I left this validation in my TODO list because I was no sure about the expected behavior if a code is wrong:
  - Shall we skip that row or is a better choice to persist it and notify the error to fix/edit the record later?

From the early beginning I had a dilemma with Sector and Parent Sector because is a clear situation where a relationship OneToMany seems the best choice.
Separated entities will create a better querying experience. Having the chance to ask to the DB for all the emissions by sector was a great PRO but adding work load to the emission's creation process was a CON.
I decided to leave it until we have a clearer view of the next steps and requirements.

With Values by year I had some doubts about validating if the year is in a range (1850..2015) and also validating the values in the cells but once again without any more info I bet for mimicking the info in the csv.

The EmissionImporter is A PORO responsible of (obviously) importing emissions.
Here we take the data from the valid existing csv and create a record for each row saving all values by year into a JSON.

The flow is completed by a rake task that calls to a job that calls to the importer.

* Adds FileValidator:
https://github.com/develaper/emissions_import/pull/2
The second PR covers the unhappy path based on this User Story:
As a user
I want to see an error message if the file is invalid.

 To take care of this responsibility I've added a new PORO named FileValidator where we can run all kind of validations for the file and its content.
 Right now the path method checks the File existence, validity and extension, raising a custom exception if something goes wrong.

 Now that we have covered the use case where the file is invalid is time to tell to the job that if our custom exception raises it should discard the job.


* TODO (Very) big CSVs and how to handle them:
After some research about handling huge csv files I found myself blocked around the idea of chunking the original file into smaller ones and using different jobs for each chunk.
I have evaluated other ideas like removing rows from the file once the data are persisted or adding a column to check later if that row has already been imported into the DB.
My main concern and reason to discard any of those strategies is that I was not really sure about:
- how were we going to interact with the file?
- Can we edit or modify it?
- Is important to keep imported files in a folder?
- Should we rename them?

Also seems a valid idea to add ImportAttempt as a new model where we can save valuable info about the import process like:
  - Errors
  - Completed
  - original file_name
  - last row imported
  .
  .
  .


So, until all those doubts are discarded or clarified I decided to use the CSV built in method foreach that seems to have the best balance between time and memory consumption.
https://dalibornasevic.com/posts/68-processing-large-csv-files-with-ruby
5 years old post but the benchmarking comparation stills legit.

 About job's retrying strategy:
 Before adding to the EmissionsImporterJob's declaration a retry statement based on a custom exception I thought that it was important to have a clearest idea about how to handle bigger csv files and a better definition of those situations where we want to retry the job but, for the record,
 It would look something like that:

 class EmissionsImporterJob < ApplicationJob
   queue_as :default
   retry_on Timeout::Error
   retry_on EmissionImporter::ProcessInterruptedException
   discard_on EmissionImporter::InvalidFileException
   .
   .
   .
 end
