#  Platform Specifics

This contains files which abstract specific platform behavior into a unified API for SHELF.

For example, there are very different pradigms for "Where is an application's data stored by default for this user?" across macOS, iOS, Windows, Linux, et al.

So this contains `URL + default directories.swift` to provide a generic API for accessing such directories.

