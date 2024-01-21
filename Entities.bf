using System;
using System.Collections;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using raylib_beef.Enums;

namespace Entities
{
	
	public enum GameState
	{
		MGM_SCREEN,
		GUNBARREL_SCREEN,
		SKYDIVING_SCREEN,
		SKELETAL_EDITOR,
		NUM_STATES
	}

	class GunbarrelDot
	{
		public Vector2 *Position { get; set;}
		public float Timer { get; set; }
		public bool Active { get; set; }
		
		public this(Vector2 position, float timer, bool active)
		{
			Position = new Vector2(position.x, position.y);
			Timer = timer;
			Active = active;
		}
	}

	class Skeleton
	{

		public Vector2 Torso {get;set;}
		public Vector2 Head {get;set;}
		public Vector2 UpperArm {get;set;}
		public Vector2 LowerArm {get;set;}
		public Vector2 UpperLeg {get;set;}
		public Vector2 LowerLeg {get;set;}
	}

	class Bone
	{
		public Vector2 Position {get;set;}
		public float Rotation {get;set;}
		public List<Bone> Children = new List<Bone>(); // maybe this should be an array? but

		public this(Vector2 position, float rotation, List<Bone> children)
		{
			Position = position;
			Rotation = rotation;
			Children = children;
		}

	}
}

