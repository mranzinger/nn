local L1HingeEmbeddingCriterion, parent = torch.class('nn.L1HingeEmbeddingCriterion', 'nn.Criterion')

function L1HingeEmbeddingCriterion:__init(margin)
   parent.__init(self)
   margin = margin or 1
   self.margin = margin
   self.gradInput = {torch.Tensor(), torch.Tensor()}
end

function L1HingeEmbeddingCriterion:updateOutput(input,y)
   self.output=input[1]:dist(input[2],1);
   if y == -1 then
	 self.output = math.max(0,self.margin - self.output);
   end
   return self.output
end


local function mathsign(t)
   if t>0 then return 1; end
   if t<0 then return -1; end
   return 2*torch.random(2)-3;
end

function L1HingeEmbeddingCriterion:updateGradInput(input, y)
  self.gradInput[1]:resizeAs(input[1])
  self.gradInput[2]:resizeAs(input[2])
  self.gradInput[1]:copy(input[1])
  self.gradInput[1]:add(-1, input[2])
  local dist = self.gradInput[1]:norm(1);
  self.gradInput[1]:apply(mathsign)    -- L1 gradient
  if y == -1 then -- just to avoid a mul by 1
   if dist > self.margin then
     self.gradInput[1]:zero()
   else
     self.gradInput[1]:mul(-1)
   end
  end
  self.gradInput[2]:zero():add(-1, self.gradInput[1])
  return self.gradInput
end

function L1HingeEmbeddingCriterion:type(type)
   self.gradInput[1] = self.gradInput[1]:type(type)
   self.gradInput[2] = self.gradInput[2]:type(type)
   return parent.type(self, type)
end
