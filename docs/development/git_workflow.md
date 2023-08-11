--- 
title: git workflow models
weight: 8.4
--- 

# git workflow models

## Trunk-Based Development

In this strategy, there's a single `master` branch where all developers work. Feature branches are short-lived and get merged swiftly into the `master` branch. Releases are directly made from the `master` branch. Trunk-Based Development pairs well with Continuous Integration and Continuous Delivery (CI/CD).

## GitFlow

GitFlow is a popular branching strategy that offers a clear structure for software development and release. Within GitFlow, there are two primary branches: `master` and `develop`. The `master` branch contains the current production releases, while the `develop` branch holds the latest development code. Additionally, there are auxiliary branches: `feature`, `release`, and `hotfix` branches.

- **Feature Branches**: Are created from `develop` and are merged back into `develop` once development is complete.
- **Release Branches**: Also originate from `develop` when preparing for a new release. Changes in this branch bump the MINOR version in SemVer. Once the release branch is finalized, it gets merged into both `master` and `develop`.
- **Hotfix Branches**: Are created from `master` when an urgent bug needs fixing. Changes in this branch bump the PATCH version in SemVer. After fixing the issue, the hotfix branch is merged back into both `master` and `develop`.

With both strategies, SemVer can be employed to distinctly define what each version contains and how it's different from prior versions. The nature of changes and the impacted branch determine which of the three components in SemVer gets incremented.
