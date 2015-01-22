module tokenizer;

import std.stdio;
import std.string;
import std.ascii;
import std.conv;


/* @todo Token should be a template<type> Token */
interface Token 
{
    //void add(Token);
    //void substract(Token);
    //void multiply(Token);
    //void divide(Token);

    //void type();
    string toString();
}

class Integer: Token 
{
    this(int v) { value = v; }
    int value;
    override string toString() { return to!string(value); }
}

class Floating: Token
{
    this(float v) { value = v; }
    float value;
    override string toString() { return to!string(value); }
}

class Operator: Token
{
    this(char v, int p) { value = v; priority = p; }
    char value;
    int priority;

    override string toString() { return to!string(value); }
}

class Parenthesis {
    static char Left = '(';
    static char Right = ')';
}
class Bracket {
    static char Left = '[';
    static char Right = ']';
}
class Brace {
    static char Left = '{';
    static char Right = '}';
}

Operator[char] Operators;
static this() {
    Operators = [
        '+': new Operator('+', 2),
        '-': new Operator('-', 2),
        
        '*': new Operator('*', 4),
        '/': new Operator('/', 4),
        '%': new Operator('%', 4),

        '^': new Operator('^', 6),
    ];
}

class Tokenizer
{
    this() {};
    ~this(){};

    void putNumber(ref const string num){
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
            tokenizer.putNumber(currentNumber);
            currentNumber.clear();

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

    tokenizer.putNumber(currentNumber);

    return tokenizer.tokens;
}