## Data fetching
- Use RTK Query hooks (createApi / injectEndpoints), not useEffect+fetch or createAsyncThunk.
- Generated hooks live in `src/services/api.ts`, imported as `useGetXQuery`, `useCreateXMutation`.
- For new endpoints, extend the existing api slice via injectEndpoints.

