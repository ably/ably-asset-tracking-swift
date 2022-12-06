# AnalyzeLocationEventFrequencies

This script is intended to help analyse the impact of restarting `CLLocationManager` each time `AblyAssetTrackingPublisher.DefaultLocationManager`’s `requestLocationUpdate` is called, specifically whether it negatively impacts:

- the frequency at which the SDK receives location updates
- the Mapbox SDK’s location recording

You can run it on a file containing log output from the publisher example app by running the following command from the current directory:

```bash
swift run AnalyzeLocationEventFrequencies <file>
```

There is an example log file `example.txt` that you can try this out on. It produces a CSV with contents like this:

|Timestamp (ISO 8601)    |Event type             |Time since last location update|Time since last recorded location|
|------------------------|-----------------------|-------------------------------|---------------------------------|
|2022-12-15T19:52:19.421Z|Recorded location      |                               |                                 |
|2022-12-15T19:52:20.035Z|Location update        |                               |                                 |
|2022-12-15T19:52:32.429Z|Recorded location      |                               |13.007                           |
|2022-12-15T19:52:32.443Z|Location update        |12.408                         |                                 |
|2022-12-15T19:52:38.433Z|Recorded location      |                               |6.004                            |
|2022-12-15T19:52:38.441Z|Location update        |5.998                          |                                 |
|2022-12-15T19:52:43.423Z|Recorded location      |                               |4.990                            |
|2022-12-15T19:52:43.439Z|Location update        |4.998                          |                                 |
|2022-12-15T19:52:47.419Z|Recorded location      |                               |3.996                            |
|2022-12-15T19:52:47.434Z|Location update        |3.995                          |                                 |
|2022-12-15T19:52:51.421Z|Recorded location      |                               |4.002                            |
|2022-12-15T19:52:51.442Z|Location update        |4.008                          |                                 |
|2022-12-15T19:52:53.428Z|Recorded location      |                               |2.007                            |
|2022-12-15T19:52:53.603Z|Request location update|                               |                                 |
|2022-12-15T19:52:53.615Z|Location update        |2.173                          |                                 |
|2022-12-15T19:52:57.420Z|Recorded location      |                               |3.992                            |
|2022-12-15T19:52:57.429Z|Location update        |3.814                          |                                 |
|2022-12-15T19:53:01.427Z|Recorded location      |                               |4.007                            |
|2022-12-15T19:53:01.433Z|Location update        |4.004                          |                                 |
|2022-12-15T19:53:04.429Z|Recorded location      |                               |3.002                            |
|2022-12-15T19:53:04.445Z|Location update        |3.012                          |                                 |
|2022-12-15T19:53:07.434Z|Recorded location      |                               |3.005                            |
|2022-12-15T19:53:07.447Z|Location update        |3.002                          |                                 |
|2022-12-15T19:53:10.433Z|Recorded location      |                               |2.999                            |
|2022-12-15T19:53:10.443Z|Location update        |2.996                          |                                 |
|2022-12-15T19:53:11.424Z|Recorded location      |                               |0.991                            |
|2022-12-15T19:53:11.923Z|Request location update|                               |                                 |
|2022-12-15T19:53:11.928Z|Location update        |1.485                          |                                 |
|2022-12-15T19:53:15.418Z|Recorded location      |                               |3.994                            |
|2022-12-15T19:53:15.433Z|Location update        |3.505                          |                                 |
|2022-12-15T19:53:19.424Z|Recorded location      |                               |4.006                            |
|2022-12-15T19:53:19.439Z|Location update        |4.006                          |                                 |
|2022-12-15T19:53:23.433Z|Recorded location      |                               |4.010                            |
|2022-12-15T19:53:23.448Z|Location update        |4.009                          |                                 |
|2022-12-15T19:53:26.420Z|Recorded location      |                               |2.987                            |
|2022-12-15T19:53:26.436Z|Location update        |2.988                          |                                 |
|2022-12-15T19:53:29.429Z|Recorded location      |                               |3.009                            |
|2022-12-15T19:53:29.445Z|Location update        |3.009                          |                                 |
|2022-12-15T19:53:33.429Z|Recorded location      |                               |4.000                            |
|2022-12-15T19:53:33.443Z|Location update        |3.998                          |                                 |
