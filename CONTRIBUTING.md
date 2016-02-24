## Release Process for this module

# Development

* features & bugfixes should be done on branches
    * naming convention: `feature/money_tree` or `bugfix/validate_credit_card`
* Update the `CHANGELOG` in the `next` section.
    * Do not create a new release number *yet*
* Submit Pull Request to `master`

# Testing
* This section is TBD. Value in testing this is going to be quite complicated and most value will come from beaker.  (Two puppet masters and an agent....   not simple!)
* TODO:
    * tests can be run inside the `ci` folder.
        * `./ci/cibuild` should be run before pushing
    * confirm this works on the CI build.
    * beaker testing
        * run any one of the tests above first to set up bundler
        * to get further assistance run: `bundle exec rake beaker_help`

# Releasing

### Steps to release a new tagged version
1. Ensure the master branch is tested
2. Create a release commit:
  1. Update `CHANGELOG` creating a section for the desired tag.
      * with version, and `next` section recreated
      * release notes made more complete (ie: review the diff from the last version for details)
  2. Ensure the `metadata.json` file is updated.
3. Create an annotated Tag with semantic versioning on `master`
    * ex: `git tag -a 0.0.2` (add some brief context)
4. Push tags `git push origin --tags`.
5. Release to the forge
6. Think about automating this process!
