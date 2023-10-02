function cbWireRead(block)

mask_state = get_param(block, 'MaskEnables');
mask_visi = get_param(block, 'MaskVisibilities'); 

if strcmp(get_param(block, 'Master'), 'Master')
    for i=[3 5]
        mask_state{i} = 'on';
        mask_visi{i} = 'on';
    end
else
    for i=[3 5]                     % 3 -> address, 5 -> command
        mask_state{i} = 'off';
        mask_visi{i} = 'off';
    end
end
set_param(block, 'MaskEnables', mask_state);
set_param(block, 'MaskVisibilities', mask_visi); 

end
