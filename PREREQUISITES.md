# How to navigate this repo

This repo is a concise (and opinionated) quickstart to setup an advance Amazon SageMaker HyperPod
cluster.

- **It assumes some level of familiarities with AWS CLI.**

- **It's meant for those who are comfortable with cross-referencing the source materials
  ([workshop](https://catalog.workshops.aws/sagemaker-hyperpod/en-US),
  [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod.html), and
  [reference
  architecture](https://github.com/aws-samples/awsome-distributed-training/tree/main/1.architectures/5.sagemaker-hyperpod)).**

- The expected workflow is: _clone this repo => edit some files => run 1+ wrapper scripts_.

## 1. Things to keep in minds all the time

1. Before running a command, _make it a habit to always review_ scripts, configurations, or whatever
   files involved. Very frequently, this repo requires you to edit files, or provides explanations,
   tips and tricks in the form of comments within various files.

2. All CLI instructions assumes the current directory is this repo, e.g., when you see these
   instructions

    ```bash
    python bin/some_example.py
    ls -al src/
    ```

    it really means

    ```console
    # Change directory to this repo. Please adjust to the actual path to the repo on your computer.
    cd /home/ubuntu/amazon-sagemaker-hyperpod-advance-quickstart

    # Then, the actual examples...
    python bin/some_example.py
    ...
    ```

3. Everytime you start a new shell, you must load the environment variables from `profile.sh`  as
   follows:

    ```bash
    # One time activity: update profile.sh. Below example use vi as the text editor
    $ vi profile.sh
    ...

    # Load env. vars to the current shell.
    $ source profile.sh

    # Sample environment variables to verify profile.sh was sourced successfully.
    $ env | grep ^SMHP_
    ```

4. `awscli` tips and tricks.

    Set the `AWS_PROFILE` and `AWS_REGION` environment variables to simplify `aws` CLI by not having
    to always specify `--profile=xxx --region=yyy` to all `aws` cli invocations.

    You may also set the `AWS_ACCOUNT` environment variable in advance to easily use this in various
    places (e.g., to include account id in your S3 bucket to ensure uniqueness).
