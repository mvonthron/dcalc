module tokenizer;

import std.stdio;
import std.string;
import std.ascii;
import std.conv;


interface Token 
{
    //void add(Token);
    //void substract(Token);
    //void multiply(Token);
    //void divide(Token);

    //void type();
}

class Integer: Token 
{
    this(int v) { value = v; }
    int value;
    auto val() { return value; }
}

class Floating: Token
{
    this(float v) { value = v; }
    float value;
    auto val() { return value; }
}

class Operator: Token
{
    this(char v) { value = v; }
    char value;
    auto val() { return value; }
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
        '+': new Operator('+'),
        '-': new Operator('-'),
        '*': new Operator('*'),
        '/': new Operator('/'),
        '^': new Operator('^'),
        '%': new Operator('%'),
    ];
}

class Tokenizer
{
    this() {};
    ~this(){};

    void putRaw(ref const string t) {
        if(t.length){
            tokens ~= t.dup;
        }
    }   

    void putRaw(char t) {
        tokens ~= to!string(t);
    }

    void print() {
        foreach(t; tokens) {
            write('(', t, ')');
        }
        writeln();
    }

    void putNumber(ref const string num){
        if(num.indexOf('.') != -1){
            tok ~= new Floating(to!float(num));
        }else{
            tok ~= new Integer(to!int(num));
        }
    }
    void put(Token t) {
        tok ~= t;
    }

    void printTokens(){
        foreach(t; tok){
            if(cast(Floating) t){
                write('<', (cast(Floating) t).value, "f>");
            }
            else if(cast(Integer) t){
                write('<', (cast(Integer) t).value, '>');
            }
            else if(cast(Operator) t){
                write(' ', (cast(Operator) t).value, ' ');
            }
        }
    }

    string[] tokens;
    Token[] tok;
}


/** tokens */
void tokenize(string str)
{

    Token[] tokens;
    auto tok = new Tokenizer;

    string currentNumber="";

    // no foreach to be able to safely consume characters in the loop
    for(auto i=0; i<str.length; i++){
        char c = str[i];
       
        if (isDigit(c) || c == '.'){
            if(c == '.' && currentNumber.indexOf('.') != -1){
                writeln("Invalid sequence: \"..\"");
                return;
            }
            currentNumber ~= c;
        }
        else if(isWhite(c)) {
            // end parsing number, otherwise ignore
            if(currentNumber.length){
                tok.putRaw(currentNumber);
                tok.putNumber(currentNumber);

                currentNumber.clear();
            }
        }
        else if(c in Operators){
            tok.putRaw(currentNumber);
            tok.putNumber(currentNumber);

            // special case: if "**" => '^'
            if(c == '*' && i<(str.length-1) && str[i+1] == '*'){
                i++;
                c = '^';
            }

            auto op = Operators[c];

            tok.putRaw(c);
            tok.put(op);

            currentNumber.clear();
        }
        else {
            writeln("*** invalid character: ", c);
            return;
        }
    }

    tok.putRaw(currentNumber);
    tok.putNumber(currentNumber);
    
    tok.print();
    tok.printTokens();
}