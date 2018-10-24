# Event Streams
Event streams exist on many objects as well as at the project level. The project is the highest level that a 
developer can explore to see all events with that particular project. 

### Exploring Event Streams
The Web Console is the primary tool to visualize events sorted by time.

- Explore the events of a pod

![](../assets/09_event_stream_01.png)

- For project wide events, navigate to `Monitoring -> Events` and select `View Details`

![](../assets/09_event_stream_02.png)

- Or on the CLI in your project 

```
oc get events --sort-by='.lastTimestamp'
```

- Navigate through some of the events and review some of the output that could be helpful 
in debugging pods