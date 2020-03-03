/*:
 # Higher Order Functions II: Functions Returning Functions
 ### (aka Functional Composition)
 
The point of this playground is to demonstrate Swift's capabilities to
 "reshape" functions - also known as functional composition.
 
 This feature is generally what people are referring to when they
 speak of `functional programming` - its use informs the entire style.
 The higher order functions from the previous playground
 are part of functional programming,
 but they are not the key distinguishing factor.  The elements of
 this playground ARE what makes functional programming different and
 makes it matter.

 Let me pause to point out that the subject matter of this playground
 seems to be where most people who are not previously familiar with
 functional programming seem to have the most problems.
 I recommend that you read it slowly and give it some serious
 thought if you are in the "most people" category.

 So... Lets start with a  function.  This one extends `Array<Int>` and
 basically gives us `compactMap` to play with.  (I'll explain much later
 in detail why we can't just use compactMap itself, but for now just note
 that its because compactMap is a generic function).
 */
extension Array where Element == Int {
    func myCompactMap(_ transform: (Int) -> String?) -> [String] {
        compactMap(transform)
    }
}

let f = [Int].myCompactMap
/*:
 Note we are extending a specific kind of Array here: `Array<Int>`.
 When you extend a generic, Swift generates a specific, unique class
 for that combination of types, i.e. [Int] is a unique class with our
 unique function assigned to it's namespace.  The functions in
 the namespace of a type just have the name of the class
 prepended to them. If you went
 and looked at the object files generated by the Swift compiler you
 would find this function amongst the symbols with exactly this name.

 Also note that `[Int].myCompactMap` is _just_ the name of a function.  We could
 have called it `foo` and made it at top level (i.e. not associated
 with a particular type).  Swift simply chose to put this function in a namespace
 associated with `[Int]` and it did that by prepending the type name as
 the namespace.

 Now take a look at the far right column of the playground.
 Expand that column so that you can see the type of the variable `f`
 there. To remind, the type of `f` is *_NOT_* `function`.  The type of `f`
 is that entire string of things produced in the results column of the
 playground to the right. Look very carefully at the type of of this
 expression and say the name of the type in your head.
 (almost everyone gets this wrong the first time they do it).
 
 Here it is printed for you:
```
    ([Int]) -> (Int -> String?) -> [String]
```
 The common mistake that almost everyone makes is this: because you
 "know" that what this function does is take an `(Int -> String?)`
 and return an `[String]`, your mind just leaves out the leading
 `([Int]) ->`
 
 This signature _should_ surprise you in several respects.
At least three questions that should be in your mind are:
 
 1. wtf? with the multiple `->`'s? and
 
 2. why do I have `([Int]) ->` at the beginning when that is nowhere in the
 signature of the function I wrote? and
 
 3. why does the middle set of things have parens around the entire
 expression instead of just around the `Int`?
 
 In words this function signature is:
```
 a function which takes [Int] and returns:
    a function which takes:
          (a function which takes an Int and returns String?)
       and returns:
          [String]
```
 Eventually in Swift, you have to understand functions-which-take-functions AND
 functions-which-return-functions. Because every function that you
 think of as an instance method is one of those functions.
 And even more you have to understand how they compose.
 
 Quick comment on the parens in the middle.  If you left them out,
 the function's signature would change from what I've just said above
 to:
 ```
  a function which takes [Int] and returns:
     a function which takes an Int and returns:
        a function which takes a String? and returns:
           [String]
 ```
 That is NOT the same function signature!
 
 The lesson here is that, by default,
 the `->` operator associates to the right.  Right association says:
 a function without any parens in place to say which is which,
 will  _return_ a function rather than _accepting_ one as an argument.
 
 Read that slowly,
 as it's very important. To specify that a function _accepts_
 a function as an argument rather than returning a function, you _must_
 put parens around the argument. This is hard to get used to because
 all of the arithmetic functions we have been taught since childhood
 associate to the left, and intuitively it seems like accepting a function
 is more important than returning one.  But that's not the convention.
 So, in this case, `( ... )` is causing the `->`
 to associate left, which is what we want.
 
 ### Higher-order Function Invocation
 
 Interestingly, there are several ways syntactically to invoke that function that
 we captured above as `f`. Look at the lines below and their type signatures.
 All of these statements are exactly the same.  The ONLY difference
 is that f1a is in OOP notation. But the compiler turns them into the
 exact same code
 as you can see over to the right where the playground prints the types.
*/
let f1a = [1,2,3].myCompactMap
let f1b =   [Int].myCompactMap([1,2,3])
let f1c = f([1,2,3])
/*:
In words `f1[a, b, c]` are all functions which
 ```
    take:
       (a function which takes an Int and returns String?)
    and return:
       [String]
 ```
 In other words, they are the original `f` function with the
 first part cut off - which is precisely the signature that
 we wrote to begin with.
 And this is as you would expect
 because we've taken the first function and done an invocation on it.

 Note that I refer above to the `OOP notation`.  In Swift,
 OOP is just that, a notation,
 nothing more, nothing less. This is one of the primary lessons of
 this playground, btw, and we'll discuss it at length below.
 
 So lets invoke the 3 functions above and see where we end up, (remember
 these functions accept as an argument an `(Int) -> String?`).
 */
let r1 = [1,2,3].myCompactMap         ( { "\($0)" } )
r1
let r2 =   [Int].myCompactMap([1,2,3])( { "\($0)" } )
r2
let r3 = f                   ([1,2,3])( { "\($0)" } )
r3
/*:
 Ok!  now we have some values.  And look, they're all the same. Which
 had better be the case or this is one wasted playground.
 
 Look closely at these two lines which we have just proven
 are _exactly_ the same (I've adjusted the whitespace to
 improve clarity):
 
     let r1 = [1,2,3].myCompactMap         ( { "\($0)" } )
     let r2 =   [Int].myCompactMap([1,2,3])( { "\($0)" } )

 What the compiler is doing with all this should
 really jump out at you now.

 What this shows is that `[1,2,3].myCompactMap` is syntactic sugar
 for what is really going on underneath which is:
 `[Int].myCompactMap([1,2,3])`.  The first is the OO notation,
 the second is the FP notation.  But they are _exactly,
 precisely, indistinguishably_ the same.

 What the Swift compiler has done anytime you do
 what you think of as Object Oriented Programming
 is take the object you are are invoking the function on and pass
 it as the first argument to a static function-returning-function.
 It then invokes the returned function, passing what you think
 of as the arguments to the method.
 
 So we've taken this `([Int]) -> (Int -> String?) -> [String]`
 thing and done _two_ function invocations to get our final
 value.
 
 ### Writing our own function-returning-function
 
 Let's revisit the type signature of `f`.  Once again, it is:
 
 `([Int]) -> ((Int) -> String?) -> [String]`

 Amazingly it is possible to write a single Swift
 function which can invert the order of those function
 invocations to:

 ` ((Int) -> String?) -> ([Int]) -> [String]`
 
 Make sure that you see what's different between those two.
 Furthermore we can make that single, inverting,
 function work even if we replace `Int` and `String`
 with any other types at all.
 
 Don't believe me? Here it is:
 */
public func flip<A, B, C>(
    _ function: @escaping (A) -> (C) -> B
) -> (C) -> (A) -> B {
    { (c: C) -> (A) -> B in
        { (a: A) -> B in
            function(a)(c)
        }
    }
}
/*:
 This is our first real example of functional composition,
 i.e. using a function to change
 the "shape" of another function or functions.  To be clear, this
 function takes a generic argument of function-returning-function type:
 
    (A) -> (C) -> B
 
 and returns something else of function-returning-function type:
 
    (C) -> (A) -> B
 
 i.e., it `flip`s the order of the C and the A.  And that's _all_
 it does.  There's nothing magic here.  It's as if in another language
 you had a function `(A,C) -> B` and you decided to change the signature
 to `(C,A) -> B` and made no other change.  It is a syntactic change
 only, with no difference in semantics.  I chose this one to start
 with precisely to avoid making you think about what it does semantically.
 
 This particular example rewards paying it a lot of
 attention, however.
 
 We have 3 functions specified here:
 
 1. the function that begins: `public func flip<A, B, C>(`
 
 2. the one that begins: `{ (c: C) -> (A) -> B in`
 
 3. the one that begins: `{ (a: A) -> B in`
 
 When invoked, function 1 returns function 2.  Function 1 is our
 original function and function 2 is that function with it's first
 two arguments "flipped" positionally. If you then invoke function 2, it
 returns function 3. If at the end of everything, you invoke function 3, you will
 _finally_ have a type that is not a function of some sort, you will have an
 "honest" value of type B. (of course B could be a function  :) )
 
 To prove it does what I said, look at the function signatures here where I have
 invoked `flip`, aka function 1:
 */
let f2   = flip(f)
let f2a  = flip([Int].myCompactMap)
/*:
 These are precisely the same functions as what we started with
 only the 1st and 2nd argument have been flipped around.
 
 Now lets use it that way by invoking function 2 which remember
 is a function-returning-function that takes `(Int) -> String?`.
 */
let f3   = f2  { "\($0)" }
f3
let f3a  = f2a { "\($0)" }
f3a
/*:
 Here's the amazing thing about that if you aren't used to the style.
 `f3` and `f3a` are functions of type `(Array<Int>) -> Array<String>`
 but I _never_ wrote a function with such a signature!
 I composed those functions from some other functions
 by passing those other functions through a higher-order function.
 And what a emerged was a completely novel function signature.
 
 One big question that should be in your mind at this point is:
 "Hey! what happened to my closure?"

     { "\($0)" }
 
 The answer
 is pretty fundamental to how OO works in Swift.  What happened
 was that when we invoked `f2` to make `f3`, that closure
 "escaped" from `f2` and was "captured" by f3. And we can't
 get it back.  As long as `f3` exists, it will have our closure
 captured inside it and will use the closure to
 process any invocation of `f3`.
 
 AND if that closure
 was using any values from the surrounding environment at
 that time, the values _AT THAT TIME_ will be captured as
 well and _enclosed_ in the captured closure.  This notion
 of "enclosing" captured variables is, in fact, the reason
 that it is called a "closure".
 
 _This_ is what is meant by _functional composition_.
 We wrote a new function whose return value was the composition
 of it's input functions.
 
 The forms
 that composition can take are many and varied.  For now we are dealing
 with some simple ones, but if you are actually curious about how the
 Combine library works its magic,
 the best statement of what its doing is that Combine consists
 of functions to compose functions which compose functions.
 (It can all get a bit self-rerential after a while).
 
 Anyway, one of the big ways that people judge a feature in the Swift language
 now is based on how well that feature composes.  It's that important.
 When property wrappers were initially proposed for the language, the
 proposal (by a member of Apple's Swift core team no less)
 was bounced, because the wrappers did not compose well.
 Let that be a lesson to you.
 
Now lets take the final step and invoke function 3...
*/
f3([1,2,3])
f3a([1,2,3])
/*:
 Ok, you ask, this is all nice and everything, but it seems kind of
 academic, where would _ANYONE_ ever use this stuff.  Well, it turns out
 that Swift itself uses this stuff as should be obvious from above where we typed:
 
    [Int].myCompactMap
 
 and got back a function-returning-function. So lets explore that a bit more.
 
 Lets define some structs of our own with some functions
 */
struct StructA {
    var a: String = "An A"
    func append(string: String) -> String {
        return a + string
    }
}
type(of: StructA.append)
/*:
 By now you should have expected this to be a function-returning-function.
 Specifically it's signature is:

     (StructA) -> (String) -> String

 Note that that means that the following two invocations are
 exactly the same, it's just that one
 of them is in OO notation while the other is just a plain
 function call.  (You should be able to say which is which
 on your own at this point).  The point is that they are
 invoking exactly the same functions in precisely the same
 order.
*/
let s1 = StructA                 .append(StructA(a: "some string"))(string: " 5")
let s2 = StructA(a:"some string").append                           (string: " 5")
/*:
 All that happened there was that `StructA(a:"some string")`
 moved from before the append to immediately after and its place
 was taken by the name of its type.

 Now look at the following extension.
 */
extension StructA {
    static func staticAppend(_ a: StructA) -> (String) -> String {
        let `self` = a
        return { string -> String in
            return `self`.a + string
        }
    }
}
/*:
 Lets get the signature of _THAT_ and compare it with the previous
 "instance method" version of `append`:
 */
type(of: StructA.staticAppend)
type(of: StructA.append)
/*:
 And, if we look at calling static append, the call and the result
 look _exactly_ like the call to `s1` above.

 In fact, if you look at those two type signatures, you'll find that
 a) are exactly the same as each other
 and b) they still fit our `flip` function signature
 perfectly.  i.e. we could shift around the order of the arguments
 if we found that convenient.

 So let's invoke the new function.
 */
let s3 = StructA.staticAppend(StructA(a: "some string"))(" 5")
/*:
 The big lesson here is that we can write our own static functions that
 bind `self` and they behave _precisely_ the way that "instance methods"
 on objects do,  i.e.
 everything you think of as an "instance method" is actually a
 function-returning-function where Swift has passed in "self" to the
 first function, which
 has bound it and returned the function that you think of as the "method".
 (The compiler
 optimizes the hell out of this for your methods, so it's not guaranteed
 to always be literally true underneath,
 but from a syntactic standpoint, they are exactly the same). And
 this precisely explains our questions up above about what all
 those extra `->`'s were doing in our simple method attached to a struct.
 
 What we've learned is that every "method" on a Swift type is actually
 just a static function-returning-function with the name of the type somehow
 prepended to put it in the correct namespace.  Swift keeps track
 of these things and provides the syntactic sugar to let you fool yourself
 into thinking that somehow it's "Object Oriented" but underneath,
 it's all just static functions and some syntactic sugar to hide
 the function-returning-function aspect from you.

 Let me say it
 another way: you could do everything you think of in Swift as OOP
 by giving static functions appropriate names and never actually
 "attaching" them to your structs and enums.
 
 Btw, if you are familiar with ObjC, what we have done
 here is _exactly_ equivalent to what ObjC
 does when it passes `self` as the first argument to an `IMP`.
 (here's [great article](https://www.cocoawithlove.com/2008/02/imp-of-current-method.html)
 on how that works, btw)

 Swift does exactly the same thing in its OO notation, it
 just uses a different technique for designating `self`.  And it turns
 out that that technique is just a normal use of functional composition.
 
 But... we can in fact do what ObjC does, too.  Let's write a function for that.
 */
public func uncurry<A, B, C>(
    _ function: @escaping (A) -> (B)  -> C
) -> (A, B) -> C {
    { (a: A, b: B) -> C in
        function(a)(b)
    }
}
/*:
 This one takes as its only argument a function-returning-function
 and returns just a regular ol' function. Here
 it is more clearly:

     ((A) -> (B) -> C) -> (A,B) -> C

 So the arguments to the passed-in function are single values and it
 combines them to make a single function that takes two arguments.
 Lets try it.
 */
let u = uncurry(StructA.append)
/*:
 Look at the output of that.  If you are familiar with other OO
 languages like ObjectiveC, it should remind you of exactly what those languages
 do to provide method invocation.
 
 To reiterate, we just turned `StructA.append` into an ObjC-style IMP where `self`
 is the first argument.  Hmm..  What can be seen here again is that everything you think
 of as OOP is in fact a specific notation that can be derived by manipulating
 functions and seasoning to taste with syntactic sugar.

 All that Swift has done
 is to promote these techniques from being compiler magic to being run-of-the-mill,
 garden variety, language features.

 And.... just for kicks, lets undo what we just did.
 */
public func curry<A, B, C>(
    _ function: @escaping (A, B) -> C
) -> (A) -> (B) -> C {
    { (a: A) -> (B) -> C in
        { (b: B) -> C in
            function(a, b)
        }
    }
}

let c = curry(u)
type(of: c)
/*:
 And we see that c recovers the shape of the original function.
 
 This sort of "shape manipulation" is a surprisingly powerful feature
 of functional programming that allows you to glue existing functions
 together in really interesting ways.
 
 NB, everything we've just done, could also be done in e.g. Java or ObjC.
 There are two differences (and the differences are the entire
 reason that these techniques are not used there):
 
 1. generics and
 2. syntax.
 
 `flip`, `curry` and `uncurry` are real, simple, one-line
 generic functions with reified implementations, created on demand.
 Unlike in Java or ObjC, generics are not just hints to the compiler.
 Reified generics are precisely what is required to remove the boiler-
 plate code necessary to reshape functions in a general sense.
 
 Without reified generics, you end up writing custom code to do
 each desired reshaping. And you don't get the boilerplate for
 different types of reshaping generated for you automagically.
 It turns out that that custom code is just
 too cumbersome to implement in the volume you would need to accomodate
 the type signature of every function you might want to reshape somehow.
 So no one ever does reshaping like this in Java or ObjC or Python et al.
 
 The syntax of Swift is _designed_ (aka stolen from other languages)
 to make this use of generics and this sort of reshaping really easy.
 It's just what modern functional languages do.
 
 In fact, [this NSHipster article](https://nshipster.com/callable/) is
 an excellent explantion of what the syntactic sugar here is doing and
 why it is so useful.
 
 Let's do one more function that is useful in this regard,
 forward composition, which we'll describe as the `>>>` operator.
 */

precedencegroup CompositionPrecedence {
  associativity: right
  higherThan: AssignmentPrecedence
  lowerThan: MultiplicationPrecedence, AdditionPrecedence
}
infix operator >>>: CompositionPrecedence

func >>> <A, B, C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C
) -> (A) -> C {
    { (a: A) -> C in g(f(a)) }
}
/*:
 Up to now we've been reshaping single functions to our liking.
 But note that this function takes _two_ functions
 which "fit together"
 as arguments . I.e. f outputs g's input type. And it rolls them up into
 one function.  And notice that we enforce that the functions
 must fit together, because they both use the same generic type `B`,
 one in output position, one in input position.
 
 (Incidentally, this starts to explain why the standard style in Swift
 when doing long function declarations is to put every argument
 on a separate line and to put the return value on its own line as well.
 Arguments that describe functions can have very long type declarations and you
 need, mentally, to be able to correctly conceive of the type of each
 in order to reason about the function as a whole.  If I tried to
 put more than one argument on a line, the `->` parts would dominate the
 naming parts and you'd be unable to figure out the compiler messages
 when you got it wrong.  And you will _always_ get something wrong).

 Anyway, here's an example of using our new `>>>` operator:
 */
let left = { (a: Int) -> Double in Double(2 * a) }
type(of: left)

let right = { (b: Double) -> String in "\(b)" }
type(of: right)
/*:
 First lets call it the way you probably would in another language
 */
right(left(4))
/*:
 Now lets call it with our cool new operator.
 */
(left >>> right)(4)
type(of: left >>> right)
/*:
 Note how `(left >>> right)` is in parens and the result of the `>>>`
 is then evaluated with the value `4`.

 Now let's save that expression in parens to a variable and look
 at the variable's type.
 */
let combined = left >>> right
type(of: combined)
/*:
 Sure 'nuff it's a single function composed from other functions.
 And note that it's signature forgets about the use of `Double`
 to join the two functions.  `Double` in fact has had its
 type _erased_ from the final signature.
 
 The term _type erasure_ is going to come up again later, for now
 be aware that what it means is that types
 that are used internally to a function are removed from the externally
 vended function signature.  In this case we returned `(Int) -> String`,
 and not `(Int) -> Double -> String` as we could have.
 */
combined(4)
/*:
 Note how all of these produce the exact same result:
 ```
     right(left(4))
     (left >>> right)(4)
     combined(4)
 ```
 
 So look closely at that line:
 
     let combined = left >>> right
 
 Using a functional composition technique,
 we were able to combine two functions together _without invoking
 either one_. And this chain can be extended as far as we like
 because >>> is like addition only for functions.  Just
 like you can say:
 
     1 + 2 + 3 + 4 ...
 
 you can also say:
 
     a >>> b >>> c >>> d ...
 
 And there's a real syntactic beauty here
 as well.  In the first form `right(left(4))`, `right` is invoked
 _after_ `left` has been evaluated, yet that's not the
 way it reads to normal English speakers who read left to
 right.  Functional techniques with infix notation actually
 let us make our code more naturally readable!
 
 While this operator and a handful of others
 are _very_ commonly used across most
 functional languages, we won't be using it in this class.
 We _will_ however be extensively using left to right functional
 chaining that incorporates this and plenty of other
 compositional techniques, we just won't be using operators
 other than the "`.`" operator.
 So you need to be aware that this particular composition
 technique is as fundamental to functional programming
 as addition is to arithmetic and that you need to understand
 how to use it just as well as you understand how to
 calculate a tip at a restaurant.
 
 Going back again:
 
     let combined = left >>> right
 
 gave us a single function which we could then invoke
 at our leisure.  Which we then do with the lines:
 ```
 combined(4)
 combined(5)
 ```
 Maybe it's belaboring the point, but what we have done with
 `left >>> right` is exactly equivalent to:
 */
func leftright(_ val: Int) -> String { right(left(val)) }
/*:
 Only we built a function like that at run time rather than
 compile time.

 This is the essence of functional composition.  You dynamicaly
 build up new functions from old ones _without invoking the old ones_
 or laboriously writing the composed functions or calling hugely
 nested invocations.
 
 So lets summarize the important points before we move on. We learned:
 
 1. how to read and work with functions-which-return-a-function
 aka _functional composition_
 2. how capture works when passing functions into function-composing-functions
 3. how type erasure works
 4. how Swift uses these techniques in it's OO notation form
 
 And now... we are ready to talk about what Combine does.
 */
