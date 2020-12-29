package main

import (
	"errors"
	"fmt"
	"math"
	"math/rand"
	"sync"
	"time"
)

// Result structure is used to store the index from the tasks slice and the result string the task returned
// (task success or task failed)
type Result struct {
	index int
	result string
}


//Job structure is used to divide the tasks slice. It stores the startIndex (the index of the first element of the
// sub-slice in the original tasks list) and a sub-slice of tasks.
type Job struct  {
	startIndex int
	tasks []func() (string, error)
}


// task simulates the execution of a task with a 50% probability of failure. In order to change the probability, modify
// the probabilityOfFailure variable to any number between 0 and 1. The task takes between 0 and 1000 milliseconds
// to complete. To make tasks potentially take longer, modify the maxTaskTime variable.
var probabilityOfFailure = 0.5 //Made global to calculate expected amount of tasks to be successful.
func task() (string, error) {
	maxTaskTime := 1000
	x := rand.Float64()
	time.Sleep(time.Duration(rand.Intn(maxTaskTime)) * time.Millisecond)
	if x <= probabilityOfFailure {
		return "task failed", errors.New("task failed")
	}
	return "task success", nil
}


// worker receives a Job from the jobs channel. It attempts each task in the tasks sub-slice up to "retry" times and
// sends the Result of the task to the results channel if the task does not fail.
func worker(ID int, jobs <- chan Job, results chan <- Result, retry int, wg *sync.WaitGroup)  {
	job := <-jobs //Receive a Job
	fmt.Println("Worker", ID, "received a job!")
	for index, task := range job.tasks { //Iterate through the tasks from the job.
		for attempt:= 0; attempt<retry; attempt++ {// Attempt the task "retry" amount of times
			message, err := task()
			if err == nil {//The task was successful; send Result to results channel and break from attempt loop.
				results <- Result{index: job.startIndex + index, result: message}
				break
			}
		}
	}
	fmt.Println("Worker", ID, "is done!")
	wg.Done()
}


// ConcurrentRetry breaks a slice of tasks into "concurrent" amount of slices. Each sub-slice is passed to a concurrent
// worker (who attempts each assigned task upto "retry" times).
func ConcurrentRetry(tasks []func() (string, error), concurrent int, retry int) <-chan Result {
	//Create the jobs and results channels
	jobs := make(chan Job, len(tasks))
	results := make(chan Result, len(tasks))

	//Create a sync WaitGroup to ensure the function waits for all the workers to finish
	var wg sync.WaitGroup
	//Add the amount of workers to the WaitGroup
	wg.Add(concurrent)
	//Break up the tasks slice into "concurrent" slices and assign one to each concurrent worker
	for i:=1; i<=concurrent; i++ {
		startIndex := (i-1)*len(tasks)/concurrent
		endIndex := (i)*len(tasks)/concurrent
		workerTasks := tasks[startIndex:endIndex]
		jobs <- Job{startIndex, workerTasks}
		go worker(i, jobs, results, retry, &wg)
	}

	wg.Wait() // Wait until all workers are done
	close(results) // Close the results channel.

	return results
}

func main() {
	// Parameters for the function
	var tasks []func() (string, error)
	numberOfTasks := 100
	concurrent := 10
	retry := 2

	// Fill the tasks slice
	for i:=0; i<numberOfTasks; i++ {
		tasks = append(tasks, task)
	}

	//Run the ConcurrentRetry function and calculate its elapsed time
	startTime := time.Now()
	results := ConcurrentRetry(tasks, concurrent, retry)
	elapsedTime := time.Since(startTime)

	// Print the results stored in the results channel.
	count := 0
	for result := range results {
		fmt.Println("Received result:", result)
		count++
	}

	//Print some additional data
	probabilityOfSuccess := 1.0-math.Pow(probabilityOfFailure, float64(retry))
	fmt.Println(math.Round(probabilityOfSuccess*float64(numberOfTasks)), "tasks are theoretically expected to be successful")
	fmt.Println(count, "out of", numberOfTasks, "tasks completed successfully.")
	fmt.Println("Took", elapsedTime, "to complete")

}