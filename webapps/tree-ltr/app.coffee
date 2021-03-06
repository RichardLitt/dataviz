DEMO_HASH = 'QmTkzDwWqPbnAh5YiV5VwcTLnGdwSNsNTn2aDxdXBFca7D'  # example viewer directory
DEBUG = false

app = ->
  hash = window.location.hash[1..]
  debug hash
  if hash.length > 0
    render hash
  else
    window.location.hash = '#'+DEMO_HASH
    window.location.reload()

render = (hash) ->
  API_REFS_FORMAT = encodeURIComponent '<src> <dst> <linkname>'
  apiPath = "/api/v0/refs?arg=#{hash}&recursive&format=#{API_REFS_FORMAT}"
  debug apiPath
  d3.xhr apiPath, (error, xhr) ->
    debug arguments
    data = xhr.responseText
    tree = {}

    refApiPattern = /"Ref": "(\S+) (\S+) (\S+)[\\n]?"/g
    while match = refApiPattern.exec data
      [whole, src, dst, linkname] = match
      tree[src] ?= []
      tree[src].push
        Hash: dst
        Name: linkname

    children = getDecendants hash, tree

    @root = children: children
    debug JSON.stringify @root, null, 2
    @root.x0 = h / 2
    @root.y0 = 0
    @root.children.forEach toggleAll
    update @root

getDecendants = (ref, dict) ->
  throw new Error unless ref? and dict?
  children = dict[ref]
  if children?
    for child in children
      throw new Error unless child.Hash?
      decendants = getDecendants child.Hash, dict
      child.children = decendants if decendants?
    children

debug = (args...) ->
  if DEBUG
    console.debug args...

app()



# Format of internal `tree`:
#
# {
#   "Qmcav25eTinMV632w9zdyXsFENDz5FCWjrMEVU7Nzy2v98": [
#     {
#       "Name": "app.js",
#       "Hash": "QmZs8mitpfSZM8TaFas9WaDVF77aQvb47UEPR1g1quoQq9"
#     },
#     {
#       "Name": "lib",
#       "Hash": "QmSXq83RU9YFnxGS7N29gBqjMXTg3qHERzrfFZxKYCGknM"
#     }
#   ],
#   "QmSXq83RU9YFnxGS7N29gBqjMXTg3qHERzrfFZxKYCGknM": [
#     {
#       "Name": "d3.js",
#       "Hash": "QmbgWP6n7wmczy9YP79FpDRUjYhyjVKjdDHTm9SS9nadZR",
#     }
#   ]
# }


# Final D3 format:
#
# {
#   "Name": "",
#   "children": [
#     {
#       "Hash": "QmZs8mitpfSZM8TaFas9WaDVF77aQvb47UEPR1g1quoQq9",
#       "Name": "app.js"
#     },
#     {
#       "Hash": "QmSXq83RU9YFnxGS7N29gBqjMXTg3qHERzrfFZxKYCGknM",
#       "Name": "lib",
#       "children": [
#         {
#           "Hash": "Qmei6UeQ3LKeKUfzKLx8SRsmxVpvvWrLmZTkKapCoQnYgf",
#           "Name": "d3",
#           "children": [
#             {
#               "Hash": "QmbgWP6n7wmczy9YP79FpDRUjYhyjVKjdDHTm9SS9nadZR",
#               "Name": "d3.js"
#             }
#           ]
#         }
#       ]
#     }
#   ]
# }
