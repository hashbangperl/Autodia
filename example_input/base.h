class Base 
{
public:
    int field;
    void baseMethod() { this->field = 1; };
    virtual void virtualMethod() = 0;
};

class Derived : public Base 
{
public:
    virtual void virtualMethod() { this->field = 2; };
};

