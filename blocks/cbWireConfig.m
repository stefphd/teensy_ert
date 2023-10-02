function cbWireConfig(block)

mask_state = get_param(block, 'MaskEnables');
mask_visi = get_param(block, 'MaskVisibilities'); 

if strcmp(get_param(block, 'Master'), 'Master')
    mask_state{3} = 'on';
    mask_visi{3} = 'on';
    mask_state{4} = 'off';
    mask_visi{4} = 'off';
else
    mask_state{3} = 'off';
    mask_visi{3} = 'off';
    mask_state{4} = 'on';
    mask_visi{4} = 'on';
end
set_param(block, 'MaskEnables', mask_state);
set_param(block, 'MaskVisibilities', mask_visi); 

end
