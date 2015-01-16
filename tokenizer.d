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
}

class Floating: Token
{
    this(float v) { value = v; }
    float value;
}

class Operator: Token
{

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

    string[] tokens;
    Token[] t;
}


/** tokens */
void tokenize(string str)
{

    Token[] tokens;
    auto tok = new Tokenizer;

    string currentNumber="";
    bool isFloatingNumber=false;

    foreach(i, c; str){
       
        if (isDigit(c)){
            currentNumber ~= c;
        }
        else if(isWhite(c)) {
            // end parsing number, otherwise ignore
            if(currentNumber.length){
                tok.putRaw(currentNumber);
                currentNumber.clear();
                isFloatingNumber=false;
            }
        }
        else if(c == '.'){
            currentNumber ~= c;
            isFloatingNumber=true;
        }
        //else if(c in Operators){

        //}
        else if(c == '+' || c == '-' || c == '*' || c == '/'){
            tok.putRaw(currentNumber);
            tok.putRaw(c);

            currentNumber.clear();
            isFloatingNumber=false;
        }
        else {
            writeln("*** invalid character: ", c);
            currentNumber.clear();
            isFloatingNumber=false;
        }
    }

    tok.putRaw(currentNumber);

    tok.print();
}