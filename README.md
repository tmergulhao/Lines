Lines
=====

A simple feed reader for iOS

Features to be implemented:

- Contextual feed list with image assets for RSS, Atom and Podcast delegations;
- Subscribe extension for Safari and others with feed discovery for given domain or plain text;
- Silence trigger on feed list;
- Reader later list with caching;
- iCloud sync for feeds and read later;
- Readability mode.

Design guidelines:

- No webviews. All links are to be open on Safari or a SafariViewController;
- No sublists on 1.0. Lines are to be created later;
- No integrated post options, only iOS sharesheets and extensions.

Ideas for later releases:

- Twitter, Soundcloud, Instagram, Dribbble and GitHub lines.
- Contextual lines.
