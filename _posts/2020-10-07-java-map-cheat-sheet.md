---
layout: post 
title: "[Java] Java Map cheat sheet for myself"
date: 2020-10-07
excerpt: "Every Java Map command I use frequently"
tags: [Java, Map, absinthe4902]
feature: /assets/img/Java_logo_icon.png
comments: false
---
# Map

> computeIfPresent - update value with more style

```java
Map<String, Integer> test = new HashMap<String, Integer>() {{
		put("ME", 25);
		put("Mom", 67):
}}:

test.computeIfPresent("Me", (k, v) -> v + 1);
```

> computeIfAbsent - put k, v when the key is not there

```java
test.computeIfAbsent("Sister", k -> 25);
```

Once, I wanted to use computeIfPresent and computeIfAbsent at once. My intend was (1) put (key, value) in specific map when ther is no key.  And later, when the map meet the same key again, then update value. I missed the point. Thoese two method cannot be condition processer and operator at the same time. So I just gave a go with old fasioned way. 

```java
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

```java
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
