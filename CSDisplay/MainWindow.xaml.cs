using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;

namespace CSDisplay
{
    /// <summary>
    /// Logique d'interaction pour MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        byte[] BArray;
        WriteableBitmap BitmapStream;
        int width = 1920;
        int height = 1080;
        int bytesPerPixel = (PixelFormats.Rgb24.BitsPerPixel) / 8;
        Stopwatch timer = new Stopwatch();

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            var dpiX = 96d;
            var dpiY = 96d;
            var pixelFormat = PixelFormats.Rgb24;
            var stride = bytesPerPixel * width;
            BArray = new byte[bytesPerPixel * width * height];
            
            var bitmap = BitmapImage.Create(width, height, dpiX, dpiY, PixelFormats.Rgb24, null, BArray, stride);
            BitmapStream = new WriteableBitmap(bitmap);
            WritableImageControl.Source = BitmapStream;

            DispatcherTimer updater = new DispatcherTimer();
            updater.Tick += new EventHandler(updater_Tick);
            updater.Interval = new TimeSpan(0, 0, 0, 0, 16);
            timer.Start();
            updater.Start();
        }

        private unsafe void updater_Tick(object sender, EventArgs e)
        {
            timer.Stop();
            TestLabel.Content = timer.ElapsedMilliseconds.ToString();
            BitmapStream.Lock();
            byte* src = (byte*)BitmapStream.BackBuffer.ToPointer();
            Random rand = new Random((int)System.Diagnostics.Stopwatch.GetTimestamp());
            int index = rand.Next(width * height * bytesPerPixel);
            src = src + index;
            byte val = 255;
            *src = val;
            int pixel = index / bytesPerPixel;
            float y = ((float)pixel) / width;
            float x = pixel - (((int)y) * width);
            BitmapStream.AddDirtyRect(new Int32Rect(Math.Min(Math.Abs((int)x - 5),width-10), Math.Min(Math.Abs((int)y-5),height-10), 10, 10));
            //BitmapStream.AddDirtyRect(new Int32Rect(0, 0, width, height));
            BitmapStream.Unlock();
            timer.Restart();
        }

    }
}
