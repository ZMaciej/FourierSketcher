int partition(Complex arr[], int low, int high) 
{ 
  double pivot = arr[high].Mag();
  int i = (low-1); // index of smaller element 
  for (int j=low; j<high; j++)
  { 
    // If current element is smaller than or 
    // equal to pivot 
    if (arr[j].Mag() <= pivot) 
    { 
      i++; 

      // swap arr[i] and arr[j] 
      Complex temp = arr[i]; 
      arr[i] = arr[j]; 
      arr[j] = temp;
  }
} 
// swap arr[i+1] and arr[high] (or pivot) 
  Complex temp = arr[i+1]; 
  arr[i+1] = arr[high]; 
  arr[high] = temp;

return i+1;
} 


/* The main function that implements QuickSort() 
 arr[] --> Array to be sorted, 
 low  --> Starting index, 
 high  --> Ending index */
 
public void sort(Complex arr[], int low, int high){
if (low < high) 
  { 
    /* pi is partitioning index, arr[pi] is  
     now at right place */
    int pi = partition(arr, low, high); 

    // Recursively sort elements before 
    // partition and after partition 
    sort(arr, low, pi-1); 
    sort(arr, pi+1, high);
  }
}

// it is not used in main program
public Complex[] sortByMagnitude(Complex arr[], int low, int high) 
{ 
  Complex[] toReturn = new Complex[arr.length];
  for(int i=0; i< arr.length; i++)
  {
    toReturn[i] = arr[i];
  }
  
  sort(toReturn,low, high);
  
  return toReturn;
}

public Complex[] SortByFourierOrder(Complex arr[])
{
  Complex[] toReturn = new Complex[arr.length];
  
  for(int i=0; i< arr.length; i++)
  {
    if(i%2==0)
      toReturn[i]=arr[i/2];
      else
      toReturn[i]=arr[arr.length-((i+1)/2)];
  }
  
  return toReturn;
}
