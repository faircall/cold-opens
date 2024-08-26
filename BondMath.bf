using System;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;

namespace BondMath
{
	public class Matrix2
	{
		// this is row major
		public float X1;
		public float Y1;
		public float X2;
		public float Y2;

		public this(float x1, float y1, float x2, float y2)
		{
			X1 = x1;
			Y1 = y1;
			X2 = x2;
			Y2 = y2;
		}

		public static Matrix2 Allocate2DRotationMatrix(float angle)
		{
			Matrix2 result = new Matrix2(Math.Cos(Trig.DegToRad(angle)), -1.0f*Math.Sin(Trig.DegToRad(angle)), Math.Sin(Trig.DegToRad(angle)), Math.Cos(Trig.DegToRad(angle)));
			return result;
		}

		public static Vector2 Matrix2MultVec2(Matrix2 m, Vector2 v)
		{
			float x = m.X1 * v.x + m.Y1*v.y;
			float y = m.X2 * v.x + m.Y2*v.y;
			Vector2 result = Vector2(x, y);
			return result;
		}

		public static Vector2 RotateVector2(Vector2 v, float angle)
		{
			Matrix2 rotMatrix = Matrix2.Allocate2DRotationMatrix(angle);
			Vector2 result = Matrix2MultVec2(rotMatrix, v);
			delete rotMatrix;
			return result;
		}

		public static float Vector2Length(Vector2 a)
		{
			return Math.Sqrt(a.x*a.x + a.y*a.y);
		}

		public static void Vector2Normalize(ref Vector2 a, float tolerance)
		{
			if (Vector2Length(a) <= tolerance)
			{
				return;
			}

			float len = Vector2Length(a);
			a.x /= len;
			a.y /= len;
		}

		public static Vector2 Vector2Normalized(Vector2 a, float tolerance)
		{
			Vector2 result = a;
			if (Vector2Length(a) <= tolerance)
			{
				return a;
			}

			float len = Vector2Length(a);
			result.x /= len;
			result.y /= len;
			return result;
		}

		public static float Vector2Distance(Vector2 a, Vector2 b)
		{
			return Math.Sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y));
		}

		public static Vector2 Vector2Scale(Vector2 a, float s)
		{

			Vector2 result = Vector2(a.x * s, a.y * s);
			return result;
		}

		public static Vector2 Vector2Subtract(Vector2 a, Vector2 b)
		{
			// a - b
			Vector2 result = Vector2(a.x - b.x, a.y - b.y);
			return result;
		}

		public static Vector2 Vector2Add(Vector2 a, Vector2 b)
		{
			// a - b
			Vector2 result = Vector2(a.x + b.x, a.y + b.y);
			return result;
		}
	}

	public class Trig
	{
		public static float DegToRad(float deg)
		{
			return Math.PI_f * deg / 180.0f;
		}

		
	}

	

	
}
