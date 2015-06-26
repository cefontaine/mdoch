

# Conditional Parallelism #
Dynamically decide parallelism at runtime, e.g., according to the parallelism overhead.

# Nested Loops #
There are significant overhead when `for` loop is nested in another loop,
because of [overhead of nested loops](BasicLanguage#Nested_Loops.md). There are three alternatives to
remove the overhead of a inner loop:
  * Use `while` statement to construct a loop
  * Use `iter` function to construct your own iterator
  * Use multidimentional loop, if it is doable

---
# Iteration Syntax #
```
for i in [3..1 by -1] do writeln(i); // NG
for i in [1..3 by -1] do writeln(i); // OK
```


---

# Deadlock by  nested domains #
Following code is dangerous, which can cause deadlock since mutex lock is associated to each array.
```
record rec { var a: [1..10] int};
record recrec { var b: rec};
var arr: [1..10] recrec;
```
Though compiler may give error messages under some circumstances, using multi-dimensional array instead is safe.


---

# Overloading "=" operator for record #
```
record rec { var x, y: real}
record nstrec { var x, y: rec}

proc =(r: rec, val: (real, real) {  //inout intent not work here
   r.x = val(1);
   r.y = val(2);
}

rec = (1.0, 1.0);      // rec.x = 1.0
nstrec.x = (1.0, 1.0)  // nstrec.x.x = 0.0, nstrec.x.y = 0.0, Not work

// Guarantee the value is copied back
proc =(r: rec, val: (real, real) {
   var r2: rec;
   r2 = val(1);
   r2 = val(2);
   return r2;
}
```


---

# Use proper data type for vector: tuple or record? #
Tuple should be used to implement vector array in Chapel because of performance advantage, especially for 2D-vector.

See [evaluation of vector performance](BasicLanguage#Arithmetic_and_Vector_Manipulation.md) for more details.


---

# Dynamic array allocation #
In Chapel, array is essentially associated with _domain_. Therefore, by assigning new ranges to domain that defines the array, user can allocate/reallocate array at runtime. For example,
```
var DomA: domain(1) = [1..2]; // Dummy initialization
var A: [DomA] int; // "A" now has two elements of type int

// Somewhere else
DomA = [1..100];  // Now "A" has 100 elements of type int
A(100) = 100;

DomA = [1..10,1..10]; // NG, must have the same rank
```

See [eval/array.chpl](http://code.google.com/p/mdoch/source/browse/eval/array.chpl) for more details.