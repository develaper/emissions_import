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
Now that the environment is up and working, in a different tab, we can run the task:
rake emissions:import_csv

At this point we have our job ready to be processed.
Check it out here:
http://localhost:3000/sidekiq/

To end the flow we can force the execution with the command:
bundle exec sidekiq

And now, if we check again the number of Emission.count in the rails console again we will notice a huge increment.


* A note about Figaro, environments and storage:
For testing purpose I have committed and pushed the storage folder and sub-folders as well as the config/application.yml file but under no reason I would never in my live do it in a real environment.
Just saying ;-)
