This is a really small example that demonstrates https://github.com/ghcjs/jsaddle/issues/64

To run:
```
cabal new-run
```

Then open http://localhost:8085/ in your browser and click the button.

On chrome it works fine.
Under firefox it errors with:
```
Error : Unexpected Duplicate. syncCallbacks=True nBatch=2 nExpected=4
```
and the app spins sending many requests to `jsaddle-warp`.
