AI Log (Copilot)


2025-10-18
- Asked to create base database for grocery items and implemented item search logic on the add item page
  Why?: less time consuming (instead of individually creating one of 50+ grocery items in the database, generating them required a lot less time).

2025-10-19
- Asked to how to retrieve items from database and add them to list (the logic for adding items to the main page)
  Why?: Needed to display the items a user searches for from the database in 'add to cart' screen on the main page of the app.

- Asked how to show items underneath a category when it's button is clicked (Implemented filter logic for cart items)
  Why?: Needed for organization of items, and give the user the abillity to browse the items they added by their given categories.

2025-10-22
- Asked to switch the checklist to utilize actual database items instead of strings.
  Why?: Grammar errors, or a misspelling of an item in the checklist search resulted in no progression of the checklist bar, as the checklist has no way of telling if the item searched for there is the same as an item in the database. Using DB items only prevents this.

2025-10-23
- Asked to generate a checklist screen for when the checklist bar is opened
  Why?: before this, when a user created a checklist, there was no UI for them to interact with once it was established (meaning things like looking at what items you marked off/haven't marked off the checklist was not possible). This screen allows the user to check what items they still need, and makes for easier usage of the checklist feature.

2025-10-25
- Asked to remove all logic and UI for product priority, including urgent weekly popups and PrioritySelector widget.
  Why?: Deprecated feature- We decided to implement some elements of this (like the popup notification of buying an item marked 'urgent' again) in the re-subcription feature. Easier to remove mentions of it across the project this way.

- Asked to limit search results and make the results container scrollable on checklist screen
  Why?: Searchbar on the checklist screen was causing a bottom overflow error, even with only 3 most relevant items showing- To combat this, a scroll was added to the search results container to prevent it from increasing in height while still returning a reasonable amount of items.

2025-10-25
- Asked to update barcode scanner page styling: scan button, category container, and add to cart button now 
match the colors on add to cart to fit the rest of the app
  Why?: Visual consistency across the app.