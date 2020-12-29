import javax.imageio.{IIOException, ImageIO}
import java.io.{File, FileNotFoundException}
import java.awt.image.BufferedImage

import scala.util.Sorting.quickSort
import scala.io.StdIn.readInt
import scala.io.StdIn.readLine
import util.control.Breaks._
import scala.collection.parallel.immutable.ParRange
import akka.actor.{Actor, ActorSystem, Props}

class ServerReport(val img:BufferedImage, val processingTime:Long)


class Client extends Actor {

  def receive: Receive = {
    case img: BufferedImage => println(self.path.name + " received the image")
      val seqServer = context.actorOf(Props[SequentialServer], "SequentialServer")
      val parServer = context.actorOf(Props[ParallelServer], "ParallelServer")
      println("Sending image to: " + seqServer.path.name)
      seqServer ! img
      println("Sending image to: " + parServer.path.name)
      parServer ! img
    case report: ServerReport => println(self.path.name + " received image from: " + sender.path.name)
      println("The server processed the image in:  " + report.processingTime + " ms")
      val pathname = "out/"+ sender.path.name + "Img.png"
      ImageIO.write(report.img, "png", new File(pathname))
      println("The image has been stored in: " + "\"" + pathname + "\"")

  }

}

class SequentialServer extends Actor {

  def receive: Receive = {
    case img: BufferedImage => println(self.path.name + " is processing the image")
      val startTime = System.currentTimeMillis()
      val outputImg = medianFilterSequential(img)
      val endTime = System.currentTimeMillis()
      sender() ! new ServerReport(outputImg, endTime - startTime)
  }

  def medianFilterSequential(img: BufferedImage): BufferedImage = {
    // A 3X3 window is used. For different dimensions change these variables.
    val windowWidth = 3
    val windowHeight = 3
    // Create a new Image with the same width and height and window array
    val output = new BufferedImage(img.getWidth, img.getHeight, BufferedImage.TYPE_INT_RGB)
    val window = new Array[Int](windowWidth * windowHeight)

    // Iterate through all windows
    val edgex = windowWidth/2
    val edgey = windowHeight/2
    for (x <- edgex until img.getWidth - edgex) {
      for(y <- edgey until img.getHeight - edgey) {
        // Fill the window array
        img.getRGB(x-edgex, y-edgey, windowWidth, windowHeight, window, 0, windowWidth)
        // Sort the window array
        quickSort(window)
        // Set the rgb value of the median of the window at x, y coordinate
        output.setRGB(x, y, window(windowWidth*windowHeight/2))
      }
    }
    // Return the new Image
    output
  }
}

class ParallelServer extends Actor {

  def receive: Receive = {
    case img: BufferedImage => println(self.path.name + " is processing the Image")
      val startTime = System.currentTimeMillis()
      val outputImg = medianFilterParallel(img)
      val endTime = System.currentTimeMillis()
      sender() ! new ServerReport(outputImg, endTime - startTime)
  }

  def medianFilterParallel(img: BufferedImage): BufferedImage = {
    // A 3X3 window is used. For different dimensions change these variables.
    val windowWidth = 3
    val windowHeight = 3
    // Create a new Image with the same width and height
    val output = new BufferedImage(img.getWidth, img.getHeight, BufferedImage.TYPE_INT_RGB)

    // Iterate through all windows
    val edgex = windowWidth/2
    val edgey = windowHeight/2
    for (x <- ParRange(edgex, img.getWidth - edgex, 1, inclusive = false)) {
      for(y <- ParRange(edgey, img.getHeight - edgey, 1, inclusive = false)) {
        // Fill the window array
        val window = img.getRGB(x-edgex, y-edgey, windowWidth, windowHeight, null, 0, windowWidth)
        // Sort the window array
        quickSort(window)
        // Set the rgb value of the median of the window at x, y coordinate
        output.setRGB(x, y, window(windowWidth*windowHeight/2))
      }
    }
    // Return the new Image
    output
  }
}

object Main {
  def main(args: Array[String]): Unit = {
    // Welcome message
    println("Welcome to the median filtering client!")

    // Prompt user for an image.
    var img: BufferedImage = null
    var pathname: String = null
    var errorMessage: String = null

    while(img == null) {
      println("Please select one of the following options:\n" +
        "1. Process the defaut test image\n" +
        "2. Specify the path to the image to be processed")
      val selectedOption = readInt()
      breakable {
        if (selectedOption == 1) {
          pathname = "testImage.png"
          errorMessage = "The test Image was not found. Please make sure it is in the Project folder."
        }
        else if(selectedOption == 2) {
          pathname = readLine("Please enter the path to the image you want to process: ")
          errorMessage = "The image was not found. Please make sure the path is correct."
        }
        else {
          println("Please select a valid option!")
          break
        }
        try {
          img = ImageIO.read(new File(pathname))
        } catch {
          case fileNotFound: IIOException => println(errorMessage)
          case _ : Throwable => println("There was an error loading the image. Please try again.")
        }

      }
    }
    //Initialize the actor system.
    val actorSystem = ActorSystem("ActorSystem")

    // Send the image to the client
    val client = actorSystem.actorOf(Props[Client], "Client")
    client ! img
  }
}
