module tokenizer;

import std.stdio;
import std.string;
import std.ascii;
import std.conv;

import operator;

enum Associativity {
    Left,
    Right
}

/* @todo Token should be a template<type> Token */
interface Token 
{
    //void type();
    string toString();
}

interface Number 
{
    void Add(Number);
}

class Integer: Token, Number
{
    this(int v) { value = v; }
    int value;
    override string toString() { return to!string(value); }

    void Add(Number right) { Add(right); }
    void Add(Integer right) { writefln("Integer::Add(%d+%d)", value, right.value); }
    void Add(Floating right) { writefln("Integer::Add(%d+%d)", value, right.value); }
}

class Floating: Token, Number
{
    this(float v) { value = v; }
    float value;
    override string toString() { return to!string(value); }

    void Add(Number n) { writeln("Floating::Add"); }
}

class Operator: Token
{
    this(char v, int p, Associativity a) { value = v; priority = p; assoc = a; }
    this(char v, int p, Associativity a, Operation o) { value = v; priority = p; assoc = a; op = o; }
    char value;
    int priority;
    Associativity assoc;
    Operation op;
    override string toString() { return to!string(value); }
}

Operator[char] Operators;
static this() {
    Operators = [
        '+': new Operator('+', 2, Associativity.Left, &Add),
        '-': new Operator('-', 2, Associativity.Left),
        
        '*': new Operator('*', 4, Associativity.Left),
        '/': new Operator('/', 4, Associativity.Left),
        '%': new Operator('%', 4, Associativity.Left),

        '^': new Operator('^', 6, Associativity.Right),

        '(': new Operator('(', 0, Associativity.Left),
        ')': new Operator(')', 0, Associativity.Left),
    ];
}

class Tokenizer
{
    this() {};
    ~this(){};

    void putNumber(ref const string num){
        assert(num.length);

        if(num.indexOf('.') != -1){
            tokens ~= new Floating(to!float(num));
        }else{
            tokens ~= new Integer(to!int(num));
        }
    }
    void put(Token t) {
        tokens ~= t;
    }

    static void printTokens(Token[] tokens){
        foreach(t; tokens){
            if(cast(Floating) t){
                writef("{%f}", (cast(Floating) t).value);
            }
            else if(cast(Integer) t){
                writef("{%d}", (cast(Integer) t).value);
            }
            else if(cast(Operator) t){
                writef("%s", (cast(Operator) t).value);
            }
        }
        writeln();
    }

    Token[] tokens;
}


/** tokens */
auto tokenize(string str)
{

    Token[] tokens;
    auto tokenizer = new Tokenizer;

    string currentNumber="";

    // no foreach to be able to safely consume characters in the loop
    for(auto i=0; i<str.length; i++){
        char c = str[i];
       
        if (isDigit(c) || c == '.'){
            if(c == '.' && currentNumber.indexOf('.') != -1){
                throw new Exception("Invalid sequence: \"..\"");
            }
            currentNumber ~= c;
        }
        else if(isWhite(c)) {
            // end parsing number, otherwise ignore
            if(currentNumber.length){
                tokenizer.putNumber(currentNumber);
                currentNumber.clear();
            }
        }
        else if(c in Operators){
            if(currentNumber.length) {
                tokenizer.putNumber(currentNumber);
                currentNumber.clear();
            }
            // special case: if "**" => '^'
            if(c == '*' && i<(str.length-1) && str[i+1] == '*'){
                i++;
                c = '^';
            }

            auto op = Operators[c];
            tokenizer.put(op);
        }
        else {
            throw new Exception(format("*** invalid character: %c", c));
        }
    }

    if(currentNumber.length){
        tokenizer.putNumber(currentNumber);
        currentNumber.clear();
    }

    return tokenizer.tokens;
}