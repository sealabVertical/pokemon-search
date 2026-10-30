Successful Request:
When the API returns a successful HTTP status code (200), the application processes the JSON response and displays the Pokémon's information.

Pokémon Not Found:
When the API returns a 404 status code, the application displays a message indicating that the Pokémon could not be found.

Other API Errors:
When the API returns an unsuccessful status code other than 404, the application displays an error message.

Network and Invalid Response Errors:
Network and JSON parsing errors are caught by the screen's error handling and displayed to the user. A request that cannot complete successfully will not display a new Pokémon result.

Offline Strategy:
The application currently requires an internet connection to retrieve Pokémon information from the PokéAPI.

If offline functionality were to be implemented in the future, previously retrieved Pokémon information could be stored locally using SQLite or another local storage solution. The application could then display cached Pokémon information when an internet connection is unavailable.

New Pokémon searches would still require an internet connection unless their information had already been saved locally.
