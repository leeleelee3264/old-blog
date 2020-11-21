---
layout: post 
title: "[Java] Java Stream/Map/List cheat sheet for myself"
date: 2020-09-24 08:43:59
author: Jamie Lee
categories: Backend
tags:	Java
cover:  "/assets/img/Java_logo_icon.png"
---

# Map

> computeIfPresent - update value with more style

```javascript
Map<String, Integer> test = new HashMap<>(){{
		test.put("ME", 25);
		test.put("Mom", 67);
}};
test.computeIfPresent("Me", (k, v) -> v + 1);
```
   
> computeIfAbsent - put k, v when the key is not there

```javascript
test.computeIfAbsent("Sister", k -> 25);
```

Once, I wanted to use computeIfPresent and computeIfAbsent at once. My intend was (1) put (key, value) in specific map when ther is no key.  And later, when the map meet the same key again, then update value. I missed the point. Thoese two method cannot be condition processer and operator at the same time. So I just gave a go with old fasioned way. 

```javascript
// in this case, I had to extract keys to merge the list value.
// in the meantime, I updated value as well. 

List<SampleInfoVO> infoById = sampleDao.getValueFromDb(param); 
Map>Integer, String> combineInfo = new HashMap<>();

for (SampleInfoVO single : infoById) {
	if(parsedStt.get(single.getUploadVoiceId()) == null) {
                parsedStt.put(single.getUploadVoiceId(), single.getTranscript());
                continue;
            }

            // maybe I should have used string builder for string operating
            parsedStt.computeIfPresent(single.getUploadVoiceId(), (k, v) -> v + single.getTranscript());
        }
```

## ComputeIfAbsent vs putIfAbsent

In Map built-in method, ComputeIfAbsent and PutIfAbsent are very much similar. Main purpose is 'put key and value when the key isn't there'. But I found that computeIfAbsent is better for saftey and performance. 

- putIfAbsent always create value object even if key exist in map.
- putIfAbsent also put null in value.

Let's say we spend high cost to make List. putIfAbsent make ("key", new ArrayList) at fisrt and go check the key. On the other hand, computeIfAbsent go check the key first and if there is no key, then make ("key", new ArrayList). No waste. 

```javascript
public class MapTest {

    static Map<Integer, String> testMap;

    static {
        testMap = new HashMap<>();
        testMap.put(1, "Pizza");
        testMap.put(2, "IceCream");
    }

    static void printMap(Map<?, ?> param) {
        param.entrySet().forEach(System.out::println);
    }

    public static void main(String [] args) {
        testMap.computeIfAbsent(3, k-> "Coffee");
   
        testMap.putIfAbsent(4, null);
        testMap.computeIfAbsent(5, k -> null);

        printMap(testMap);
				// result 1=Pizza 2=IceCream 3=Coffee 4=null
    }
}
```
In this result, there is no 5 in testMap. Because computeIfAbsent ignore an attempt to put null in map. But 4 is indeed in the map. putIfAbsent doesn't care much. Perfect answer is [here!](https://stackoverflow.com/questions/48183999/what-is-the-difference-between-putifabsent-and-computeifabsent-in-java-8-map)

## init and insert at once with computeIfAbsent AKA dream comes true  
I just thought init and insert at once without if was not possible but I found that I was wrong.  
Just write computeIfAbsent first to make init value container (in this case, List) and append the rest command that you need to save the value in the container.  
It will execute computeIfAbsent when the container doesn't have a key after that, it will execute the rest code. If the container has code, it will just ignore the first command line. 

```javascript
public class StreamTest {

    private List<PojoSample> sampleListContainer;

    {
        sampleListContainer = new ArrayList<>();
        PojoSample one = new PojoSample(1, "Jamie", "Korea");
        PojoSample four = new PojoSample(1, "Jamie", "Canada");
        PojoSample two = new PojoSample(2, "Travis", "Canada");
        PojoSample three = new PojoSample(3, "Naomi", "Japan");

        sampleListContainer.add(one);
        sampleListContainer.add(two);
        sampleListContainer.add(three);
        sampleListContainer.add(four);
    }

    @Test
    public void testComputeIfAbsent() {
        Map<Integer, List<PojoSample>> pojoById = new HashMap<>();

        for(PojoSample single: sampleListContainer) {
            pojoById.computeIfAbsent(single.getId(), k -> new ArrayList<>()).add(single);
        }
    }
}
```


# Stream
## Collections.disjoint AKA checking if one list contains an element in the other list

Sometimes, we have to check if the given list has element in the other list. I usually liked to use for-loop to dig in. But as we know. The simpler, the better.  
Collections.disjoint help me up with this. In the document, they say it will return <strong>true</strong> if the two list doesn't have a common.  
When I take a look at the method, it consists with (1) for loop (2) contains from collection. It means the performance is the same with for loop.  
In an answer of StackOverFlow, if I need to search a large list, then I had better use <strong>HashSet</strong>
More info is [here!](https://stackoverflow.com/questions/21830970/java-arraylist-contains-vs-for-loop)

```javascript
 List<Integer> rs1 = Arrays.asList(1,2,3,4,4);
 List<Integer> rs2 = Arrays.asList(5,6,7,8);
 System.out.println(Collections.disjoint(rs1, rs2));

 Set<Integer> rs1Set = new HashSet<>(rs1);
 System.out.println(Collections.disjoint(rs1Set, rs2));
```

If it is possible, think about use the first list to set in Collections.disjoint(). It will show better performance. It is in the official document! 
We can say it's matter of memory and speed. Want less memory? Just go with two list. Want more speed? Go with one set one list.
```
  public static boolean disjoint(Collection<?> c1, Collection<?> c2) {
        // The collection to be used for contains(). Preference is given to
        // the collection who's contains() has lower O() complexity.
        Collection<?> contains = c2;
        // The collection to be iterated. If the collections' contains() impl
        // are of different O() complexity, the collection with slower
        // contains() will be used for iteration. For collections who's
        // contains() are of the same complexity then best performance is
        // achieved by iterating the smaller collection.
        Collection<?> iterate = c1;

        // Performance optimization cases. The heuristics:
        //   1. Generally iterate over c1.
        //   2. If c1 is a Set then iterate over c2.
        //   3. If either collection is empty then result is always true.
        //   4. Iterate over the smaller Collection.
        if (c1 instanceof Set) {
            // Use c1 for contains as a Set's contains() is expected to perform
            // better than O(N/2)
            iterate = c2;
            contains = c1;
        } else if (!(c2 instanceof Set)) {
            // Both are mere Collections. Iterate over smaller collection.
            // Example: If c1 contains 3 elements and c2 contains 50 elements and
            // assuming contains() requires ceiling(N/2) comparisons then
            // checking for all c1 elements in c2 would require 75 comparisons
            // (3 * ceiling(50/2)) vs. checking all c2 elements in c1 requiring
            // 100 comparisons (50 * ceiling(3/2)).
            int c1size = c1.size();
            int c2size = c2.size();
            if (c1size == 0 || c2size == 0) {
                // At least one collection is empty. Nothing will match.
                return true;
            }

            if (c1size > c2size) {
                iterate = c2;
                contains = c1;
            }
        }

        for (Object e : iterate) {
            if (contains.contains(e)) {
               // Found a common element. Collections are not disjoint.
                return false;
            }
        }

        // No common elements were found.
        return true;
    }
```

## (1) Extract value from List and joining, (2) How to convert int to String in List  
Collectors.joining() is very similar with String.join(). Both methods containing string values with inputed character.  
And Sometime I have to change int value to string doing something like Collectors.joining() method. First map will extract value from the list and second map convert extracted int value to string.  
```
public class StreamTest {

    private List<PojoSample> sampleListContainer;

    @Test
    public void testJoiningAndConverting() {
       String nameJoin = sampleListContainer.stream().map(PojoSample::getName).collect(Collectors.joining("/"));
       String intConvertJoin = sampleListCOntainer.stream().map(PojoSample::getId).map(String::valueOf).collect(Collectors.joining("/"));
    }
}
```
