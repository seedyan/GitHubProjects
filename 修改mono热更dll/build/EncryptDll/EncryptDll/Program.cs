using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EncryptDll
{
	class Program
	{
		static void Main(string[] args)
		{
			Console.WriteLine(args.Length);

			string dllName = "Assembly-CSharp";
			if (args.Length > 0)
			{
				dllName = args[0];
			}

			string newDllName = dllName + "_new";
			if (args.Length > 1)
			{
				newDllName = args[1];
			}

			Encrypt(dllName, newDllName);

			//Decrypt(newDllName);

			Console.WriteLine("Encrypt end.");
		}

		private static void Encrypt(string orgName, string newName)
		{
			FileStream fs = new FileStream(orgName + ".dll", FileMode.OpenOrCreate);
			// fs.Length是long，若文件太多，length有出错的风险
			int fileLength = (int)fs.Length;
			byte[] buff = new byte[fileLength];
			// 读取dll文件内容
			fs.Read(buff, 0, fileLength);
			// 对dll内容进行处理
			buff[0] += 0x23;
			buff[1] -= 0x23;

			int halfLength = fileLength / 2;
			int subHalfLength = halfLength / 2;
			int lastIndex = halfLength - 1;
			for (int idx = 0; idx < subHalfLength; ++idx)
			{
				byte tmp = buff[idx];
				buff[idx] = buff[lastIndex - idx];
				buff[lastIndex - idx] = tmp;
			}

			int leftLength = fileLength - halfLength;
			int subLeftHalfLength = leftLength / 2;
			int subLeftHalfIndex = halfLength + subLeftHalfLength;
			lastIndex = fileLength - 1;
			for (int idx = halfLength; idx < subLeftHalfIndex; ++idx)
			{
				byte tmp = buff[idx];
				buff[idx] = buff[lastIndex - idx + halfLength];
				buff[lastIndex - idx + halfLength] = tmp;
			}

			buff[0] += 0x23;
			buff[1] -= 0x23;

			fs.Close();

			// 新建文件将读取的dll内容做处理后保存
			fs = new FileStream(newName + ".dll", FileMode.Create);
			fs.Write(buff, 0, fileLength);
			fs.Close();
		}


		/// <summary>
		/// For tes
		/// </summary>
		public static void Decrypt(string name)
		{
			string newDllName = name + "_de";

			FileStream fs = new FileStream(name + ".dll", FileMode.OpenOrCreate);
			// fs.Length是long，若文件太多，length有出错的风险
			int fileLength = (int)fs.Length;
			byte[] buff = new byte[fileLength];
			// 读取dll文件内容
			fs.Read(buff, 0, fileLength);
			// 对dll内容进行处理
			buff[0] -= 0x23;
			buff[1] += 0x23;

			int halfLength = fileLength / 2;
			int subHalfLength = halfLength / 2;
			int lastIndex = halfLength - 1;
			for (int idx = 0; idx < subHalfLength; ++idx)
			{
				byte tmp = buff[idx];
				buff[idx] = buff[lastIndex - idx];
				buff[lastIndex - idx] = tmp;
			}

			int leftLength = fileLength - halfLength;
			int subLeftHalfLength = leftLength / 2;
			int subLeftHalfIndex = halfLength + subLeftHalfLength;
			lastIndex = fileLength - 1;
			for (int idx = halfLength; idx < subLeftHalfIndex; ++idx)
			{
				byte tmp = buff[idx];
				buff[idx] = buff[lastIndex - idx + halfLength];
				buff[lastIndex - idx + halfLength] = tmp;
			}

			buff[0] -= 0x23;
			buff[1] += 0x23;

			//Console.WriteLine(fs.Read(buff, 0, (int)fs.Length));
			fs.Close();

			// 新建文件将读取的dll内容做处理后保存
			fs = new FileStream(newDllName + ".dll", FileMode.Create);
			fs.Write(buff, 0, fileLength);
			fs.Close();
		}
	}
}
