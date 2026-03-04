# ``NewsApp``

An app to display news articles, chosen depending on the categories of news and its news sources. Data is fetched from https://newsapi.org/. 
Consists of 3 Screens:
- Category Screen: Displays a table view with 7 categories available from newsapi (data is provided locally as newsapi does not have an api to fetch available categories, instead they list all the possible categories), which will determine and move the screen into the Sources Screen.

- Sources Screen: Displays a table card view of news sources with the related category choosen prior via api. User can use the search bar provided to search the available sources. The search is dynamic and done locally as newsapi does not have a q query to search for sources via api and has no pagination options (return all sources all at once). Selecting one of the sources will move the screen into Articles Screen.

- Articles Screen: Displays articles based on the specified sources choosen prior via api. The data is paginated into 20 per page, and the pagination will be triggered when user scrolls to the bottom (endless scroll). User can use the search bar provided to search for the available articles. The search is based on user clicking search on keyboard. This is because of the pagination nature (we don't know how many possible data is available, so it would be risky to blindly load all the data). The search is done by calling API again with the q query. When user taps the article, it will open a web view that redirects user to the news article.

## User Story:
Create a mobile native application to show news using API from https://newsapi.org/. You might
need to create an account to get an API key.
- Main screen: Create a screen to display a category list of news.
- Source screen: Show news sources when a user clicks one of the news
categories.
- Article screen: Show news article when user clicks one of the news sources.
- Webview news screen: Show the article detail on WebView when the user clicks one of
the articles.
- Source screen & Article screen: Provide a function to search news sources and article
screen.
- Source screen & Article screen: Implement endless scrolling on news sources and
articles screen.
- Cover positive and negative cases. E.g internet error, etc.

## Packages Used
- Kingfisher: used to handle image loading from URL with built in caching images to lighten the load and fasten load time when the same URL is encountered again for images.
- IQKeyboardManager: used to handle keyboard related logics, such as text field movement when keyboard is obstructing and dismissing when not touching the text field globally.

## API Section Used
API used from https://newsapi.org/. is the top-headlines one, not the everything, because the user story has the need for a main screen with category, in which source opens the source from the selected category, and continues into articles. This is not supported with everything, and is supported by top-headlines. This is why top-headlines is used.
