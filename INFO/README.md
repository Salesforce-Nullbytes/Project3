Project 3 for Revature Salesforce cohort
Candidate Evaluation of Apex Coding Skills
  - Dual Package
  - Due February 3

Client subproject allows deployment of SF candidate evaulation packages,
retrival and publishing of test results to candidate, internal reporting
for evaulating candidates' coding skills.

Candidate subproject includes experience site for registration and info.
It will authenticate the user and provide test packages from the client.
Candidate may then install the package on Trailhead org, and use the
provided app to begin the examination.

Prompts will be provided with Apex class specifications, and the candidate
must write a class to meet the criteria. Tests classes will be included to evaulate 
the correctness, completeness, or efficiency of each submission.

When a candidate begins the exam, a timestamp is posted to the database.
When a submission is made, a test suite is run and results are sent to client server.
The next question is then timestamped for its start time, the prompt changed, and
the process repeates for each questions.

The evaluation metrics may inclulde passes, fails, and more from ApexTestResult.
Alternatively, a question may be for a test class to evaluate code coverage on a set of 
non-test classes provided in the package.

As evaluation challenges are completed, test result data is sent to client server
over REST api (and saved in client org). When no challenges remain, client org will
generate a report of results to the candidate over REST api.

Client org must include custom reporting to visualize candidates individually and
in aggregate. Simplicity, design, and ease-of-use are emphasized.

Client org must have a process for managing evaluation packages, their prompt and sequence
data, and the distribution to authenticated candidates. Assurances must be made that the user cannot 
retrieve the test classes from SFDX and game system to pass questions.