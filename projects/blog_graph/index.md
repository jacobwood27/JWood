@def title="Blogroll Graph"

\note{Objective}{Familiarize myself with some network analysis and investigate the information space around some of the blogs I visit.}

Many blogs include a [blogroll](https://en.wikipedia.org/wiki/Glossary_of_blogging) on their page with links to other blogs. I thought it might be interesting to try to map the network that emerges from blogs linking to one another.

You can find the finished product [here](https://jacobwood27.github.io/035_blog_graph/).

# Data

### Collection
Data was collected by manually visiting each site, looking for something like a blogroll, and extracting the links with the help of [Link Grabber](https://chrome.google.com/webstore/detail/link-grabber/caodelkhipncidmoebgbbeemedohcdma?hl=en-US). 

I started with [astralcodexten.substack.com](https://astralcodexten.substack.com/) and continued following links as they were mentioned. 

The data format I chose was a plaintext file listing each parent node (indicated by [square brackets]) and the relevant children. This seemed to me to be a straightforward and lightweight file format for the task at hand. For example, the entry for astralcodexten.substack.com looks like:
```plaintext
[astralcodexten.substack.com]
newscience.org
applieddivinitystudies.com
nintil.com
westhunt.wordpress.com
putanumonit.com
rationallyspeakingpodcast.org
vox.com/authors/kelsey-piper
lesswrong.com
marginalrevolution.com
razib.substack.com
scottaaronson.com/blog
infoproc.blogspot.com
zeynep.substack.com
thezvi.wordpress.com
elidourado.com/blog
bayesianinvestor.com/blog
scholars-stage.blogspot.com
blogs.sciencemag.org/pipeline
forum.effectivealtruism.org
strangeloopcanon.com
slimemoldtimemold.com
freddiedeboer.substack.com
beeminder.com
cold-takes.com
goodoptics.wordpress.com
dynomight.net
```

I currently have over [300 blogs](https://github.com/jacobwood27/035_blog_graph/blob/master/blogs.txt) mapped, but am always accepting pull requests if anyone wants to add more!

### Cleaning

As with any real world application the collected data grows dirty and stale. Some links have completely disappeared, some have moved to a new domain, and some contain extraneous suffixes in the URL.

The URL will serve as a good unique ID for each blog when trying to cross-reference with other lists, so we want to distill the URL down to the minimum viable address.

We can start with some simple cleaning - remove any scheme that might be present as well as a trailing slash.

```Python
PREFIXES = [
    "https://www.",
    "http://www.",
    "https://",
    "http://",
    "www.",
]

for p in PREFIXES:
    s = s.removeprefix(p)
s = s.strip('/')
```

We also want to make sure our eventual graph contains exactly one node for each distinct blog. For example, we want to combine Andrew Gelman's old URL ([stat.columbia.edu/~gelman/blog](stat.columbia.edu/~gelman/blog)) with his new URL [statmodeling.stat.columbia.edu](statmodeling.stat.columbia.edu). While traversing through the graph I tried to record any updates to URLs. I am sure I missed some, but this dictionary is what I ended up with:

```Python
TRANSLATE = {
    "slatestarcodex.com" : "astralcodexten.substack.com",
    "the-diplomat.com" : "thediplomat.com",
    "redstate.org" : "redstate.com",
    "nelslindahl.net" : "nelslindahl.com",
    "aei.org/publication/blog/carpe-diem": "aei.org/blog/carpe-diem",
    "amlibpub.com" : "amlibpub.blogspot.com",
    "cafehayek.typepad.com/hayek" : "cafehayek.com",
    "cafehayek.typepad.com" : "cafehayek.com",
    "globalguerrillas.typepad.com/globalguerrillas" : "globalguerrillas.typepad.com",
    "stat.columbia.edu/~cook/movabletype/mlm" : "statmodeling.stat.columbia.edu",
    "stat.columbia.edu/~gelman/blog" : "statmodeling.stat.columbia.edu",
    "delong.typepad.com" : "braddelong.substack.com",
    "economistsview.typepad.com/economistsview" : "economistsview.typepad.com",
    "pjmedia.com/instapundit" : "instapundit.com",
    "stumblingandmumbling.typepad.com/stumbling_and_mumbling": "stumblingandmumbling.typepad.com",
    "andrewgelman.com": "statmodeling.stat.columbia.edu",
    "taxprof.typepad.com/taxprof_blog": "taxprof.typepad.com",
    "gnxp.com/": "razib.substack.com",
    "io9.com": "gizmodo.com/io9",
    "worthwhile.typepad.com/worthwhile_canadian_initi": "worthwhile.typepad.com",
    "rogerfarmerblog.blogspot.com": "rogerfarmer.com"
}
```

### Filtering
There are a lot of small nodes in the list that bog down the simulation and don't add much to the visualization. For now we'll just cut out anything that is referenced only one time.

```Python
old_len = 0
while len(g.vs) != old_len:
    old_len = len(g.vs)
    to_delete_ids = [v.index for v in g.vs if len(g.neighbors(v,mode="in"))==1 and len(g.neighbors(v,mode="out"))==0]
    g.delete_vertices(to_delete_ids)
```

# Processing
The network data lends itself well to analysis as a graph. [igraph](https://igraph.org/) is fantastic network analysis software and is available as a Python package.

### Community Detection
After reading the data into a directed igraph object we can easily apply state of the art community detection algorithms like [Leiden](https://www.nature.com/articles/s41598-019-41695-z) to reveal some structure in the data.

The Leiden algorithm is implemented in Python with various quality functions for use with igraph [here](https://github.com/vtraag/leidenalg). The various quality functions lead to different (similar) community definitions we want to show. We also want to make sure not to generate too many tiny communities, which are hard to pull any meaning out of, so we'll slowly decrease the `resolution_parameter` until we have a maximum of 10 communities.

```Python
import leidenalg
algos = [leidenalg.RBConfigurationVertexPartition,
         leidenalg.RBERVertexPartition,
         leidenalg.CPMVertexPartition]
max_n_groups = 10
s_res0 = 1.0
dicts = []
for algo in algos:
    n_groups = max_n_groups + 1
    s_res = s_res0
    while n_groups > max_n_groups:
        part = leidenalg.find_partition(g,algo, resolution_parameter=s_res)
        n_groups = len(part)
        s_res /= 1.2
    dic = dict()
    for (pn,p) in enumerate(part):
        for i in p:
            dic[i] = pn
    dicts.append(dic)
```

# Visualization
The visualization leverages [d3-force](https://github.com/d3/d3-force) to assemble a 2D structure from the directed graph. d3-force simulates each node as a particle and allows you to apply forces to each individual node or to the graph globally. The output is tied to SVG nodes that animate in the browser.

The forces that are applied are:
 - [Link](https://github.com/d3/d3-force#links): Pull two connected nodes together along an edge. The magnitude of this force is inversely proportional to the number of connections on the smaller of the two connecting nodes.
 - [Charge](https://github.com/d3/d3-force#forceManyBody): Push each node away from one another. The magnitude of this force is selectable in the settings.
 - [Collision](https://github.com/d3/d3-force#collision): Prevents nodes from overlapping.
 - [Center](https://github.com/d3/d3-force#centering): Translates the graph uniformly to center it in the SVG canvas.

In addition to particle interactions, we can dress the network up to make things easier to parse:
 - The size of the nodes will convey the number of incoming connections on the graph
 - The edges will be displayed at all times
   - When a node is hovered over, only the edges connected to that node will show. We can use color to differentiate incoming and outgoing connections
 - Show the label on each node
   - When hovered, show the name larger because some of the nodes are tiny
 - Allow the user to drag nodes around to encourage different visualization shapes

The final visualization is viewable [here](https://jacobwood27.github.io/035_blog_graph/).

# Ingredients
- [Leidenalg](https://github.com/vtraag/leidenalg) - Python implementation of the Leiden community detection algorithm
- [igraph](https://igraph.org/) - Network analysis software
- [d3-force](https://github.com/d3/d3-force) - JavaScript module for simulating physical forces on particles