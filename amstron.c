#include<stdio.h>
#include<conio.h>
int main()
{
   int n,rem,sum=0,n1;
   scanf("%d",&n);
    n1=n;
       while(n!=0)
       {
           rem=n%10;
           sum=sum+rem*rem*rem;
           n=n/10;
       }
   
    if(sum==n1)
    {
    printf("yes");
    }

    else
    {
    
    printf("no");
    }
    return 0;
}