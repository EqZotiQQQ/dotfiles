Dont use fallbacks if user didn't ask
## Code style
- Write code with minimal cognitive load: simple, direct, easy to read.
- When adding a feature, do not change the code style of other modules.
- If a code change makes the docs inaccurate, update the docs to match.
- Comments: English only, minimal, plain words.
## Data fetching
- Use RTK Query hooks (createApi / injectEndpoints), not useEffect+fetch or createAsyncThunk.
- Generated hooks live in `src/services/api.ts`, imported as `useGetXQuery`, `useCreateXMutation`.
- For new endpoints, extend the existing api slice via injectEndpoints.
