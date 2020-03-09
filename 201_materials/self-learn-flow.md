## Provisioning Namespaces

we need a good flow to know who is in the course and how to communicate with them.  When to provision namespaces, when to delete name spaces.

Other considerations is do we provide them with a fully open namespace that they can do anything with?


do we show instructions on how to standup minishift? (seems iffy)



## Module definition
```js
{
  "name": String,
  "learningGoal": String,
  "exercises": [
    {
      "content": [
        {
          "type": "instruction",
          "mimetype": String,
          "content": // File || Blob || String 
        },
        {
          "type": "instruction",
          "mimetype": String,
          "content": // File || Blob || String 
        },
        {
          "type": "task",
          "mimetype": String,
          "content": // File || Blob || String 
        }
      ]

    }
  ]
}
```
### Module Name

Short name for module

### Learning Goal

A concise description of what the outcome is for this module

### Exercise
<ol>
<li>Title</li>
<li>Description</li>
<li>Media (image or video)</li>
<li>Task</li>
<li>Reflection</li>
</ol>


> other notes
