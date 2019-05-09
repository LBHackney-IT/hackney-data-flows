# Hackney Data Flows

This is an attempt at documenting the flows of data from Hackney internal systems, through the various APIS that have been created, to the services that make use of those APIs.

It is not an infrastructure diagram, but rather a representation of data usages throughout the systems. It has two concepts to deal with:
 - Entities: This represents a class of data
 - System: This is an organisational unit that either consumes or produces data. It can have a dependency on an entity contained within another system.

It is not fully complete at this point, but does go some way towards documenting the state of the data flow between the systems at Hackney.
 
## Data Structure

The yaml files in the _data directory are used to define the relationships between the systems. The `dependencies` attribute in the yaml files specifies that this system relies on the entities in another system. THe name of the system is used to form the relationship between the systems. If it isn't defined in a yaml file it will be created.

Other metadata can be added to a system such as the repository, maintainers, etc. which will be generated on the system page.

## Getting started

It uses Jekyll to generate a basic site to represent the data that is visualised using Graphviz. To get started building this:
 * Install Ruby
 * Install Jekyll
 * Install graphviz on your system
 * Run `bundle install`
 * Run `jekyll serve`
 * [Browse the docs](http://localhost:4000/hackney-data-flows)

To push to GitHub pages you can use the `jgd` command which will build the site from the latest master branch on GitHub and then push to the gh-pages branch to publish the site.