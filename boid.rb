# encoding: utf-8

require "dxruby"

# 360度系の三角関数
def sin(deg);Math.sin(deg*Math::PI/180);end
def cos(deg);Math.cos(deg*Math::PI/180);end

# ２次元ベクトル
class Vec < Array
  attr_accessor :x,:y
  def initialize(x,y);@x,@y=x,y;end
  def self.[](x,y=nil)
    if y.nil? # 角度xの単位ベクトル
      Vec.new(cos(x),sin(x))
    else
      Vec.new(x,y)
    end
  end
  def +(o);Vec.new(@x+o.x,@y+o.y);end
  def -(o);Vec.new(@x-o.x,@y-o.y);end
  def /(o);@x/=o;@y/=o;self;end
  def *(o)
    case o
    when Vec
      @x*o.x+@y*o.y
    when Numeric
      @x*=o;@y*=o;self
    end
  end
  def rot(deg)
    @x,@y = cos(deg)*@x - sin(deg)*@y,sin(deg)*@x + cos(deg)*@y; self
  end
  def to_a;[@x,@y];end
end

# 鳥もどき
class Boid < Sprite
  def initialize(x,y,angle,spd)
    super(x,y,new_image)
    self.angle,@spd = angle,spd
  end

  def new_image
    color = [rand(255),rand(255),rand(255)]
    img = Image.new(16,16)
    img.triangle_fill(0,4,16,8,0,6,color)
  end

  def update
    # マウスに向かうように方向転換
    mouse_v = Vec[Input.mouse_pos_x,Input.mouse_pos_y]
    if (mouse_v - Vec[x,y])*(Vec[angle].rot(90)) > 0
      self.angle += 5
    else
      self.angle -= 5
    end

    # 移動
    self.x,self.y = (Vec[x,y] + Vec[@spd,0].rot(angle)).to_a
  end
end


BOIDS = []
Window.loop do

  if Input.mouse_down?(M_LBUTTON)
    BOIDS << Boid.new(Input.mouse_pos_x,Input.mouse_pos_y,rand(360),5)
  end

  Sprite.update BOIDS
  Sprite.clean BOIDS
  Sprite.draw BOIDS
end
