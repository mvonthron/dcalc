import std.stdio;
import std.string;
import std.container;
import tokenizer;


class Group: Token
{
    this(Token left, Operator op, Token right)
    {
        this.left = left;
        this.op = op;
        this.right = right;
    }

    override string toString()
    {
        return format("(%s %s %s)", left.toString(), op.toString(), right.toString());
    }

    Token left;
    Operator op;
    Token right;
}

Group groupify(Token[] tokens)
{

    if(tokens.length < 3 || tokens.length % 2 == 0) {  
        throw new Exception("Not enough tokens");
    }

    /* 1 + 2 * 3... => '+' */
    Token left = tokens[0];
    Operator op = cast(Operator) tokens[1];
    Token right = tokens[2];

    /* ex (3, +, 4) */
    if(tokens.length == 3) {
        writeln("group of 3");
        return new Group(left, op, right);
    }

    Operator next_op = cast(Operator) tokens[3];

    // ex: '+' followed by '*'
    if (next_op.priority > op.priority) {
        /* 1 + 2 * 3 => (1, '+', (2, '*', 3))
         *               ^   ^    `-------´
         *        left --´   `-- op    ^-- right
         */
        right = groupify(tokens[2..$]);
    } 
    // ex: '*' followed by '+'
    else {
        left = new Group(left, op, right);
        op = next_op;

        if(tokens.length == 5){
            /* 1 * 2 + 3 => ((1, '*', 2), '+', 3)
             *                `-------´    ^   ^
             *             left --^   op --´   `-- right
             */
            right = tokens[4];
        }else{
            /* 1 * 2 + 3 / 4 => ((1, '*', 2), '+', (3, '/', 4))
             *                    `-------´    ^    `-------´
             *                 left --^   op --´        ^-- right
             */
            right = groupify(tokens[4..$]);
        }
        
    }

    return new Group(left, op, right);
}

Token[] shunting_yard(Token[] infix)
{
    Token[] postfix;
    Array!Operator operators;

    foreach(token; infix) {
        Operator operator = cast(Operator) token;
        if(operator){
            if(operators.empty){
                operators.insertBack(operator);
            }else{
                auto prio = operator.priority;
                auto prev_prio = operators.front.priority;

                if(prio > prev_prio){
                    while(!operators.empty){
                        postfix ~= operators.back;
                        operators.removeBack();
                    }
                }
                operators.insertBack(operator);
            }

        }else{
            postfix ~= token;
        }
    }

    while(!operators.empty){
        postfix ~= operators.back;
        operators.removeBack();
    }

    return postfix;
}


string print_postfix(Token[] tokens)
{
    return "";
}

unittest 
{

}